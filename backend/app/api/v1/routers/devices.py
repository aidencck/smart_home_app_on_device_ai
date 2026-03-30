from fastapi import APIRouter, Depends
from redis.asyncio import Redis
from app.schemas.base import BaseResponse
from app.schemas.device import DeviceShadowUpdate
from app.services.device_service import DeviceService
from app.api.deps import get_redis

router = APIRouter()

@router.post("/shadow", response_model=BaseResponse)
async def update_device_shadow(
    update_data: DeviceShadowUpdate,
    redis: Redis = Depends(get_redis)
):
    """
    设备影子更新接口
    
    端侧发生状态改变时异步上报。
    基于 last_update_ts (Vector Clock) 解决乱序到达和旧数据覆盖新数据的问题。
    """
    await DeviceService.update_shadow(redis, update_data)
    return BaseResponse.success(message="Shadow updated successfully")

