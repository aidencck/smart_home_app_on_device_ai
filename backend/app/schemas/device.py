from pydantic import BaseModel, Field
from app.schemas.base import BaseSchema

class DeviceShadowUpdate(BaseSchema):
    """端侧上报的设备影子更新"""
    device_id: str = Field(..., description="设备唯一标识")
    state: str = Field(..., description="更新后的状态")
    last_update_ts: int = Field(..., description="端侧产生的操作时间戳 (Vector Clock)")
    is_high_risk: bool = Field(default=False, description="是否为高危设备 (如门锁、烤箱)")
