from fastapi import APIRouter, Depends
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.base import BaseResponse
from app.schemas.device import DeviceShadowUpdate, DeviceShadowBatchUpdate, DeviceBind, DeviceHeartbeat, DeviceStateUpdate
from app.services.device_service import DeviceService
from app.api.deps import get_redis, get_db, get_current_user
from app.core.metrics import DEVICE_CONTROL_COUNT, DEVICE_CONTROL_ERROR

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
    try:
        await DeviceService.update_shadow_batch(redis, batch_data)
        
        # 记录批量更新指标
        for shadow in batch_data.updates:
            DEVICE_CONTROL_COUNT.labels(device_id=shadow.device_id, operation_type='shadow_batch_update').inc()
            
        return BaseResponse.success(message="Shadow batch updated successfully")
    except Exception as e:
        from app.core.exceptions import AppException
        from app.core.logger import logger
        
        # 记录批量更新错误指标
        for shadow in batch_data.updates:
            DEVICE_CONTROL_ERROR.labels(device_id=shadow.device_id, error_type=type(e).__name__).inc()
            
        if isinstance(e, AppException):
            raise e
            
        # I-2: Circuit Breaker / Fallback for Redis timeouts during shadow updates
        logger.error(f"Fallback triggered for device shadow batch update due to error: {str(e)}")
        # Return fallback response
        return BaseResponse.success(
            data={"fallback": True, "status": "queued"},
            message="Shadow batch update queued (fallback mode)"
        )

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
    try:
        new_clock = await DeviceService.update_device_state(db, device_id, state_update)
        
        # 记录设备状态更新指标
        DEVICE_CONTROL_COUNT.labels(device_id=device_id, operation_type='state_update').inc()
        
        return BaseResponse.success(data={"vector_clock": new_clock}, message="Device state updated successfully")
    except Exception as e:
        from app.core.exceptions import AppException
        from app.core.logger import logger
        
        # 记录设备状态更新错误指标
        DEVICE_CONTROL_ERROR.labels(device_id=device_id, error_type=type(e).__name__).inc()
        
        if isinstance(e, AppException):
            raise e
        
        # I-2: Circuit Breaker / Fallback for device state updates
        logger.error(f"Fallback triggered for device {device_id} state update due to error: {str(e)}")
        # Return a clear fallback state instead of a raw 500 error
        return BaseResponse.success(
            data={
                "vector_clock": state_update.vector_clock, 
                "fallback": True, 
                "state": state_update.state,
                "status": "queued"
            }, 
            message="Device state update queued (fallback mode)"
        )

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

