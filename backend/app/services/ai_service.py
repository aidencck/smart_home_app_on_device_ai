import time
import json
import asyncio
import hashlib
from typing import Optional
from redis.asyncio import Redis
from openai import AsyncOpenAI
from app.schemas.ai import ChatRequest, ChatResponseData, CommandAction, ModelResponseFormat
from app.core.exceptions import AppException, BaseErrorCode, DeviceErrorCode
from app.core.logger import logger
from app.core.config import settings

# 初始化全局 OpenAI 客户端 (可对接 vLLM)
aclient = AsyncOpenAI(
    api_key=settings.AI_API_KEY,
    base_url=settings.AI_API_BASE
)

class AIService:
    @staticmethod
    async def process_chat_request(request: ChatRequest, redis: Redis) -> ChatResponseData:
        """
        处理端侧发起的大模型对话请求 (包含 Semantic Cache 与大模型调用)
        """
        logger.info(f"Processing chat request: {request.command_id} - Query: {request.query}")
        
        # 0. 防重放攻击 (Replay Attack): 利用 Redis SETNX 结合 Command ID 实现幂等性拦截
        # 增加 hardware_level 作为隔离域的示例（实际中应该用 user_id/home_id）
        idempotency_key = f"cmd_exec:{getattr(request, 'hardware_level', 'default')}:{request.command_id}"
        # 保留较长 TTL(24小时) 以防真正的恶意重放，正常成功后无需删除
        is_new_command = await redis.set(idempotency_key, "processing", ex=86400, nx=True)
        if not is_new_command:
            logger.warning(f"Duplicate request intercepted for command_id: {request.command_id}")
            raise AppException(
                code=BaseErrorCode.BAD_REQUEST, 
                message="指令正在处理或已处理，请勿重复提交"
            )
            
        try:
            # 1. 校验端侧设备状态快照的 Vector Clock 是否过期 (强一致性校验，防范时钟漂移)
            current_ts = int(time.time())
            for device in request.context:
                # 修复时钟漂移漏洞: 使用 abs() 防范端侧时钟快于云端的“未来时间”被放行
                if abs(current_ts - device.last_update_ts) > 60:
                    logger.warning(f"Device {device.device_id} context is stale/drifted. Triggering active probe.")
                    raise AppException(
                        code=DeviceErrorCode.STATE_STALE,
                        message=f"设备 {device.device_id} 状态快照已过期，请同步后重试"
                    )
            
            # 2. Semantic Cache 拦截层 (修复缓存投毒与 Python Hash 随机化漏洞)
            # 2.1 按设备 ID 严格排序，保证组合状态的幂等性
            sorted_context = sorted([(d.device_id, d.state) for d in request.context], key=lambda x: x[0])
            # 2.2 转换为紧凑的 JSON 字符串
            context_str = json.dumps(sorted_context, separators=(',', ':'))
            # 2.3 使用稳定的 SHA-256 生成签名，杜绝重启后缓存失效
            context_signature = hashlib.sha256(context_str.encode('utf-8')).hexdigest()
            
            # Cache Key 必须由 Query + Context Signature 共同决定，防止不同房间的同名指令串流
            cache_key = f"semantic_cache:v1:{request.query.strip().lower()}:{context_signature}"
            
            cached_result = await redis.get(cache_key)
            if cached_result:
                logger.info(f"Semantic Cache Hit for query: {request.query}")
                cache_data = json.loads(cached_result)
                
                # 成功命中缓存，更新重放锁的状态
                await redis.set(idempotency_key, "success_cache", ex=86400)
                
                return ChatResponseData(
                    command_id=request.command_id,
                    reply_text=cache_data.get("reply_text", "已执行"),
                    commands=cache_data.get("commands", [])
                )
                
            # 3. 未命中缓存，构建 Prompt 并调用大模型
            logger.info(f"Cache Miss, calling LLM: {settings.AI_MODEL_NAME}")
            context_prompt_str = json.dumps([d.model_dump() for d in request.context], ensure_ascii=False)
            
            system_prompt = f"""你是一个智能家居中控大脑。当前家庭设备状态如下：
{context_prompt_str}
请根据用户指令，输出自然语言回复和对应的设备控制指令。"""

            # 强制开启 Structured Outputs (Beta 功能，vLLM 和 OpenAI 均支持 Pydantic Schema 解析)
            completion = await aclient.beta.chat.completions.parse(
                model=settings.AI_MODEL_NAME,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": request.query}
                ],
                response_format=ModelResponseFormat,
                temperature=0.1
            )
            
            # 解析模型返回的结构化数据
            model_response = completion.choices[0].message.parsed
            
            # 4. 异步写入 Semantic Cache (建议大幅缩短强业务相关指令的缓存时间至 1 小时)
            await redis.setex(
                cache_key, 
                3600, # 缓存 1 小时
                model_response.model_dump_json()
            )
            
            # 成功处理完毕，更新防重放锁为完成状态
            await redis.set(idempotency_key, "success_llm", ex=86400)
            
            # 5. 构造并返回结果，必须原样带回 Command ID
            return ChatResponseData(
                command_id=request.command_id,
                reply_text=model_response.reply_text,
                commands=model_response.commands
            )
            
        except Exception as e:
            # 致命修复：遇到任何异常（大模型超时、状态过期等），必须主动释放防重放锁
            # 否则用户在接下来的 24 小时内（原为 300s）将无法重试该指令
            await redis.delete(idempotency_key)
            logger.error(f"Error processing command, idempotency lock released for {request.command_id}")
            if isinstance(e, AppException):
                raise e
            logger.error(f"LLM API Error: {str(e)}", exc_info=True)
            raise AppException(
                code=BaseErrorCode.INTERNAL_SERVER_ERROR,
                message="云端 AI 大脑暂时无法响应，请稍后再试"
            )
