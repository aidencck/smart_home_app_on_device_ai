from fastapi import APIRouter, Depends
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.base import BaseResponse
from app.schemas.device import DeviceShadowUpdate, DeviceShadowBatchUpdate, DeviceBind, DeviceHeartbeat, DeviceStateUpdate
from app.services.device_service import DeviceService
from app.api.deps import get_redis, get_db, get_current_user

router = APIRouter()

@router.post("/bind", response_model=BaseResponse)
async def bind_device(
    bind_data: DeviceBind,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    设备绑定接口
    
    允许用户将特定设备绑定到自己的账号下，并指定绑定角色（owner, admin, user）。
    """
    await DeviceService.bind_device(db, bind_data, current_user["id"])
    return BaseResponse.success(message="Device bound successfully")

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

@router.put("/{device_id}/state", response_model=BaseResponse)
async def update_device_state(
    device_id: str,
    state_update: DeviceStateUpdate,
    db: AsyncSession = Depends(get_db)
):
    """
    更新设备状态（支持乐观锁并发控制）
    
    必须传入当前的 vector_clock，用于防止多端并发更新导致的幽灵跳动问题。
    """
    new_clock = await DeviceService.update_device_state(db, device_id, state_update)
    return BaseResponse.success(data={"vector_clock": new_clock}, message="Device state updated successfully")

@router.post("/heartbeat", response_model=BaseResponse)
async def device_heartbeat(
    heartbeat_data: DeviceHeartbeat,
    db: AsyncSession = Depends(get_db)
):
    """
    设备心跳接口
    
    接收设备心跳，更新其 last_seen 时间并设为在线状态。
    """
    await DeviceService.update_heartbeat(db, heartbeat_data)
    return BaseResponse.success(message="Heartbeat updated successfully")

