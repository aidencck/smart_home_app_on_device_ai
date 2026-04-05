from fastapi import APIRouter, Depends, HTTPException, status
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import uuid

from app.schemas.base import BaseResponse
from app.schemas.ai import ChatRequest, ChatResponseData
from app.core.exceptions import AppException, ErrorCode
from app.services.ai_service import AIService
from app.api.deps import get_redis, get_current_user, get_db
from app.models.automation import AIRecommendation, Automation
from app.schemas.automation import AIRecommendation as AIRecommendationSchema, Automation as AutomationSchema

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

@router.get("/recommendations", response_model=list[AIRecommendationSchema])
async def get_ai_recommendations(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = current_user["id"]
    stmt = select(AIRecommendation).where(AIRecommendation.user_id == user_id)
    result = await db.execute(stmt)
    recommendations = result.scalars().all()
    return recommendations

@router.post("/recommendations/{recommendation_id}/accept", response_model=AutomationSchema)
async def accept_ai_recommendation(
    recommendation_id: str,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = current_user["id"]
    
    # 查找推荐项
    stmt = select(AIRecommendation).where(
        AIRecommendation.id == recommendation_id,
        AIRecommendation.user_id == user_id
    )
    result = await db.execute(stmt)
    recommendation = result.scalar_one_or_none()
    
    if not recommendation:
        raise HTTPException(status_code=404, detail="AI Recommendation not found")
        
    if recommendation.status != "pending":
        raise HTTPException(status_code=400, detail="Recommendation is not pending")
        
    # 更新状态为已接受
    recommendation.status = "accepted"
    
    # 创建 Automation
    automation_id = str(uuid.uuid4())
    action_payload = recommendation.action_payload
    
    # 构造默认条件（例如来自 action_payload 或者默认的某种事件）
    condition = action_payload.get("condition", {"event_type": "USER_ACCEPTED_AI"})
    action = action_payload.get("action", {})
    
    new_automation = Automation(
        id=automation_id,
        name=f"Auto from AI: {recommendation.description[:20]}",
        is_enabled=True,
        condition_json=condition,
        action_json=action,
        user_id=user_id
    )
    
    db.add(new_automation)
    await db.commit()
    await db.refresh(new_automation)
    
    return new_automation

