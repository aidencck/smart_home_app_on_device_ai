from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.api.deps import get_db, get_current_user
from app.models.automation import Automation
from app.schemas.automation import AutomationTriggerRequest, AutomationTriggerResponse

router = APIRouter()

@router.post("/trigger", response_model=AutomationTriggerResponse)
async def trigger_automation(
    request: AutomationTriggerRequest,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = current_user["id"]
    event_type = request.event_type

    # 查询该用户所有启用的自动化规则
    stmt = select(Automation).where(
        Automation.user_id == user_id,
        Automation.is_enabled == True
    )
    result = await db.execute(stmt)
    automations = result.scalars().all()

    matched_rules = 0
    actions_to_execute = []

    for auto in automations:
        # 简单的条件匹配逻辑：检查 condition_json 中是否包含对应的 event_type
        condition = auto.condition_json
        if condition.get("event_type") == event_type:
            matched_rules += 1
            # 将动作加入待执行列表
            actions_to_execute.append(auto.action_json)

    # 模拟执行动作
    return AutomationTriggerResponse(
        message="Automation triggered successfully",
        matched_rules=matched_rules,
        actions_to_execute=actions_to_execute
    )
