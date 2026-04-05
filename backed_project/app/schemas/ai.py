from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from app.schemas.base import BaseSchema

class DeviceStateSnapshot(BaseSchema):
    """设备状态快照"""
    device_id: str = Field(..., description="设备唯一标识")
    state: str = Field(..., description="当前状态, 如 'on', 'off', '26度'")
    last_update_ts: int = Field(..., description="端侧生成的状态时间戳(秒级) - Vector Clock")

class ChatRequest(BaseSchema):
    """端侧发起的大模型对话请求"""
    command_id: str = Field(..., description="端侧请求的唯一ID，用于防时序竞态 (Race Condition)")
    query: str = Field(..., min_length=1, max_length=500, description="用户脱敏后的自然语言指令")
    context: List[DeviceStateSnapshot] = Field(default_factory=list, description="当前家庭设备的状态快照")
    hardware_level: Optional[str] = Field("unknown", description="端侧硬件等级评级 (用于辅助决定路由策略)")

class CommandAction(BaseSchema):
    """下发给端侧执行的具体指令"""
    device_id: str = Field(..., description="目标设备ID")
    action: str = Field(..., description="动作，如 turn_on, set_temperature")
    parameters: Optional[Dict[str, Any]] = Field(default_factory=dict, description="动作参数")

class ModelResponseFormat(BaseSchema):
    """用于约束大模型输出的 JSON Schema 结构"""
    reply_text: str = Field(..., description="给用户的自然语言回复或语音播报文本")
    commands: List[CommandAction] = Field(default_factory=list, description="需要执行的控制指令列表")

class ChatResponseData(BaseSchema):
    """对话响应的具体业务数据"""
    command_id: str = Field(..., description="回传端侧的请求ID，供端侧拦截器校验是否过期")
    reply_text: str = Field(..., description="给用户的自然语言回复或语音播报文本")
    commands: List[CommandAction] = Field(default_factory=list, description="需要端侧 Executor 在局域网执行的控制指令")
