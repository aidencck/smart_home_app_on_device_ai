from app.worker.celery_app import celery_app
from app.core.logger import logger
from app.core.config import settings
from celery.signals import worker_process_init
import json
import httpx
from openai import OpenAI, APIConnectionError, RateLimitError

sync_client = None

@worker_process_init.connect
def init_worker(**kwargs):
    """
    保证每个 Worker 进程被 Fork 后拥有独立的连接池，解决并发污染与 SSL Handshake 报错
    """
    global sync_client
    sync_client = OpenAI(api_key=settings.AI_API_KEY, base_url=settings.AI_API_BASE)

# 启用原生指数退避机制：retry_backoff=True 配合 retry_jitter 避免重试风暴
@celery_app.task(bind=True, max_retries=3, acks_late=True, retry_backoff=True, retry_jitter=True)
def process_telemetry_log(self, log_data_json: str):
    """
    LLM-as-a-Judge 数据飞轮清洗管道
    """
    logger.info(f"Starting to process telemetry log: {log_data_json[:100]}...")
    try:
        log_data = json.loads(log_data_json)
        
        # 使用同步客户端调用大模型进行 Judge
        # prompt = "评估以下设备交互日志是否为有效的高难度样本(Hard Example)..."
        # completion = sync_client.chat.completions.create(...)
        
        # 模拟模型判断耗时
        import time
        time.sleep(0.5) 
        
        is_valid_sample = True 
        
        if is_valid_sample:
            logger.info(f"Log {log_data.get('session_id')} classified as VALID. Saved to DB.")
        else:
            logger.info(f"Log {log_data.get('session_id')} classified as NOISE. Discarded.")
            
        return {"status": "processed", "is_valid": is_valid_sample}
        
    except json.JSONDecodeError as e:
        # 确定性错误 (Deterministic Error)：比如传来的根本不是 JSON
        # 绝对不能抛出重试，直接丢弃，否则会引发队列死循环雪崩
        logger.error(f"Invalid JSON format in telemetry log, discarded: {e}")
        return {"status": "failed", "reason": "invalid_json_format"}
        
    except (APIConnectionError, RateLimitError, httpx.RequestError) as e:
        # 瞬态错误 (Transient Error)：比如 API 超时、限流、网络抖动
        # 依赖 Celery 的原生指数退避重试 (retry_backoff)
        logger.warning(f"Transient LLM API error, retrying... {e}")
        raise self.retry(exc=e)
        
    except Exception as e:
        # 兜底：其他确定性的代码 Bug 坚决不重试，直接抛出异常使任务失败进入死信队列
        logger.error(f"Deterministic error occurred: {e}", exc_info=True)
        raise

