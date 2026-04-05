from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.exc import IntegrityError
from app.models.device import Device, Binding
from app.schemas.device import DeviceShadowUpdate, DeviceShadowBatchUpdate, DeviceBind, DeviceHeartbeat, DeviceStateUpdate
from app.core.exceptions import AppException, ErrorCode
from redis.asyncio import Redis
from app.core.logger import logger
from sqlalchemy import update
from datetime import datetime, timezone

class DeviceService:
    # 修复并发竞态 (TOCTOU) 及 Lua 脚本的类型安全防崩溃问题
    LUA_UPDATE_SHADOW = """
    local current_ts = redis.call('HGET', KEYS[1], 'last_update_ts')
    local req_ts = tonumber(ARGV[1])
    
    if current_ts then
        local curr_ts_num = tonumber(current_ts)
        -- 增加防脏数据崩溃检查：只有在云端时间戳有效且大于等于请求时间戳时才拒绝
        if curr_ts_num and req_ts and curr_ts_num >= req_ts then
            return 0 -- 请求的时间戳小于等于云端，说明是乱序或旧数据，拒绝更新
        end
    end
    
    redis.call('HSET', KEYS[1], 'state', ARGV[2], 'last_update_ts', ARGV[1])
    redis.call('EXPIRE', KEYS[1], tonumber(ARGV[3]))
    return 1 -- 更新成功
    """

    @staticmethod
    async def get_device_version(redis: Redis, device_id: str) -> Optional[int]:
        """
        防腐层接口：供其他微服务（如 AI 网关）查询设备的版本号，
        避免跨领域直接访问 Redis 数据结构。
        """
        cloud_version_str = await redis.hget(f"device:shadow:{device_id}", "last_update_ts")
        if cloud_version_str:
            return int(cloud_version_str)
        return None

    @staticmethod
    async def update_shadow_batch(redis: Redis, batch_data: DeviceShadowBatchUpdate) -> dict:
        """
        批量更新云端设备影子 (Batch State Sync)
        使用 Redis Pipeline 减少网络往返开销，并在内部原子化执行 Lua 脚本
        """
        pipeline = redis.pipeline()
        
        for update_data in batch_data.updates:
            redis_key = f"device:shadow:{update_data.device_id}"
            ttl = 1 if update_data.is_high_risk else 3600
            
            # 在 Pipeline 中注册 Lua 脚本执行
            pipeline.eval(
                DeviceService.LUA_UPDATE_SHADOW, 
                1, # KEY 数量
                redis_key, # KEYS[1]
                update_data.last_update_ts, # ARGV[1]
                update_data.state,          # ARGV[2]
                ttl                         # ARGV[3]
            )
            
        results = await pipeline.execute()
        
        success_count = 0
        stale_count = 0
        
        for update_data, res in zip(batch_data.updates, results):
            if res == 0:
                logger.warning(
                    f"Vector Clock mismatch/Stale data for device {update_data.device_id}. "
                    f"Request TS: {update_data.last_update_ts}. Rejecting update via Lua."
                )
                stale_count += 1
            else:
                success_count += 1
                logger.info(f"Successfully updated shadow atomically for device {update_data.device_id} to {update_data.state}")
                
        return {
            "success_count": success_count,
            "stale_count": stale_count,
            "total_processed": len(batch_data.updates)
        }

    @staticmethod
    async def bind_device(db: AsyncSession, bind_data: DeviceBind, user_id: str) -> Binding:
        """
        设备绑定逻辑
        1. 检查设备是否存在
        2. 检查设备是否已被绑定（若是 owner 则可能需要解绑或其他逻辑，这里简单处理为不能重复绑定 owner）
        3. 创建绑定记录
        """
        # 1. 检查设备是否存在
        result = await db.execute(select(Device).where(Device.id == bind_data.device_id))
        device = result.scalars().first()
        if not device:
            raise AppException(
                code=ErrorCode.NOT_FOUND,
                message=f"Device {bind_data.device_id} not found"
            )
            
        # 2. 检查是否已经绑定
        result = await db.execute(
            select(Binding).where(
                Binding.device_id == bind_data.device_id,
                Binding.user_id == user_id
            )
        )
        existing_binding = result.scalars().first()
        if existing_binding:
            raise AppException(
                code=ErrorCode.BAD_REQUEST,
                message="Device already bound to this user"
            )
            
        # 3. 创建绑定关系
        new_binding = Binding(
            user_id=user_id,
            device_id=bind_data.device_id,
            role=bind_data.role
        )
        db.add(new_binding)
        
        # 可选：如果是 owner，可能需要更新 Device 表的 tenant_id 等信息
        # 如果当前用户有 tenant_id，我们也可以将设备归属于该租户
        
        try:
            await db.commit()
            await db.refresh(new_binding)
        except IntegrityError:
            await db.rollback()
            raise AppException(
                code=ErrorCode.CONFLICT,
                message="Device already bound"
            )
        
        logger.info(f"User {user_id} successfully bound device {bind_data.device_id} as {bind_data.role}")
        return new_binding

    @staticmethod
    async def update_device_state(db: AsyncSession, device_id: str, state_update: DeviceStateUpdate) -> int:
        """
        更新设备状态（乐观锁/Vector Clock防并发覆盖）
        """
        # 1. 查询设备及当前状态
        result = await db.execute(select(Device).where(Device.id == device_id))
        device = result.scalars().first()
        
        if not device:
            raise AppException(
                code=ErrorCode.NOT_FOUND,
                message=f"Device {device_id} not found"
            )
            
        # 2. 校验 vector_clock 解决并发竞态问题
        if device.vector_clock != state_update.vector_clock:
            raise AppException(
                code=ErrorCode.CONFLICT,
                message=f"Device state conflict. Current vector_clock is {device.vector_clock}, but got {state_update.vector_clock}"
            )
            
        new_clock = device.vector_clock + 1
        # 3. 更新状态和 vector_clock
        stmt = (
            update(Device)
            .where(
                Device.id == device_id,
                Device.vector_clock == state_update.vector_clock
            )
            .values(
                state=state_update.state,
                vector_clock=new_clock,
                updated_at=datetime.now(timezone.utc)
            )
        )
        update_result = await db.execute(stmt)
        
        # 4. 二次确认更新结果（如果由于并发修改导致 rowcount == 0，也抛出异常）
        if update_result.rowcount == 0:
            raise AppException(
                code=ErrorCode.CONFLICT,
                message="Device state conflict during update."
            )
            
        await db.commit()
        logger.info(f"Successfully updated state for device {device_id}, new vector_clock: {new_clock}")
        return new_clock

    @staticmethod
    async def update_heartbeat(db: AsyncSession, heartbeat_data: DeviceHeartbeat) -> None:
        """
        更新设备心跳时间并设为在线
        """
        stmt = (
            update(Device)
            .where(Device.id == heartbeat_data.device_id)
            .values(last_seen=datetime.now(timezone.utc), is_online=True)
        )
        result = await db.execute(stmt)
        if result.rowcount == 0:
            raise AppException(
                code=ErrorCode.NOT_FOUND,
                message=f"Device {heartbeat_data.device_id} not found"
            )
        await db.commit()
        logger.debug(f"Device {heartbeat_data.device_id} heartbeat updated.")

