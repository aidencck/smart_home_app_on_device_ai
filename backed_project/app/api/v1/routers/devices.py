from fastapi import APIRouter, Depends
from redis.asyncio import Redis
from app.schemas.base import BaseResponse
from app.schemas.device import DeviceShadowUpdate, DeviceShadowBatchUpdate
from app.services.device_service import DeviceService
from app.api.deps import get_redis

router = APIRouter()

@router.post("/shadow/batch", response_model=BaseResponse)
async def update_device_shadow_batch(
    batch_data: DeviceShadowBatchUpdate,
    redis: Redis = Depends(get_redis)
):
    """
    设备影子批量更新接口 (Batch State Sync)
    
    端侧发生状态改变时合并上报。
    基于 last_update_ts (Vector Clock) 解决乱序到达和旧数据覆盖新数据的问题。
    """
    await DeviceService.update_shadow_batch(redis, batch_data)
    return BaseResponse.success(message="Shadow batch updated successfully")

