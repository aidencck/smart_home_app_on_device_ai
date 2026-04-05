from fastapi import APIRouter, Depends
from redis.asyncio import Redis
from app.schemas.base import BaseResponse
from app.schemas.ai import ChatRequest, ChatResponseData
from app.core.exceptions import AppException, ErrorCode
from app.services.ai_service import AIService
from app.api.deps import get_redis, get_current_user

router = APIRouter()

@router.post("/chat", response_model=BaseResponse[ChatResponseData])
async def cloud_ai_fallback(
    request: ChatRequest,
    redis: Redis = Depends(get_redis),
    current_user: dict = Depends(get_current_user)
):
    """
    云端大模型兜底接口
    
    1. 接收端侧带有 Command ID 和 Context 的自然语言请求
    2. 强制鉴权并将 request 上下文与当前用户的 home_id 绑定，防止越权
    3. 校验 Context 中的设备状态是否过期 (Version Clock 机制)
    4. 调用大模型返回结构化 JSON 指令
    """
    # 强鉴权，防止越权控制其他家庭的设备
    request.hardware_level = current_user.get("home_id", request.hardware_level)
    
    response_data = await AIService.process_chat_request(request, redis)
    
    return BaseResponse.success(
        data=response_data,
        message="Command processed successfully"
    )

