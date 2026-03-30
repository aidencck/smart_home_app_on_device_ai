from app.schemas.device import DeviceShadowUpdate
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
    async def update_shadow(redis: Redis, update_data: DeviceShadowUpdate) -> bool:
        """
        更新云端设备影子 (基于 Vector Clock 与 Lua 原子操作解决异步并发乱序问题)
        """
        redis_key = f"device:shadow:{update_data.device_id}"
        
        # 高危设备不缓存或设置极短的 TTL (0s/1s)，每次强制要求最新探针数据
        ttl = 1 if update_data.is_high_risk else 3600
        
        # 执行原子化 Lua 脚本
        result = await redis.eval(
            DeviceService.LUA_UPDATE_SHADOW, 
            1, # KEY 数量
            redis_key, # KEYS[1]
            update_data.last_update_ts, # ARGV[1]
            update_data.state,          # ARGV[2]
            ttl                         # ARGV[3]
        )
        
        if result == 0:
            logger.warning(
                f"Vector Clock mismatch/Stale data for device {update_data.device_id}. "
                f"Request TS: {update_data.last_update_ts}. Rejecting update via Lua."
            )
            raise AppException(
                code=ErrorCode.STATE_STALE,
                message="设备状态时间戳过期或乱序，更新被拒绝"
            )
        
        logger.info(f"Successfully updated shadow atomically for device {update_data.device_id} to {update_data.state}")
        return True
