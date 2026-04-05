from pydantic import Field
from typing import Dict, Any, List
from app.schemas.base import BaseSchema
from app.schemas.ai import DeviceStateSnapshot

class TelemetryLog(BaseSchema):
    """端侧 Opt-in 授权上报的脱敏日志"""
    session_id: str = Field(..., description="临时会话ID (绝不能包含真实用户ID)")
    failed_query: str = Field(..., description="导致失败的用户指令")
    error_reason: str = Field(..., description="端侧记录的失败原因 (如 format_error, unsupported_action)")
    device_context: List[DeviceStateSnapshot] = Field(default_factory=list, description="当时的设备快照")
    app_version: str = Field(..., description="当前 App 版本")
