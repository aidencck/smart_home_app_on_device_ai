from app.schemas.device import DeviceShadowUpdate, DeviceShadowBatchUpdate
from app.core.exceptions import AppException, ErrorCode
from redis.asyncio import Redis
from app.core.logger import logger

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
