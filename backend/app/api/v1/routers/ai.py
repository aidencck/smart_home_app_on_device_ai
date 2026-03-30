from fastapi import APIRouter, Depends
from redis.asyncio import Redis
from app.schemas.base import BaseResponse
from app.schemas.ai import ChatRequest, ChatResponseData
from app.core.exceptions import AppException, ErrorCode
from app.services.ai_service import AIService
from app.api.deps import get_redis

router = APIRouter()

@router.post("/chat", response_model=BaseResponse[ChatResponseData])
async def cloud_ai_fallback(
    request: ChatRequest,
    redis: Redis = Depends(get_redis)
):
    """
    云端大模型兜底接口
    
    1. 接收端侧带有 Command ID 和 Context 的自然语言请求
    2. 校验 Context 中的设备状态是否过期 (Vector Clock 机制)
    3. 调用大模型返回结构化 JSON 指令
    """
    response_data = await AIService.process_chat_request(request, redis)
    
    return BaseResponse.success(
        data=response_data,
        message="Command processed successfully"
    )

