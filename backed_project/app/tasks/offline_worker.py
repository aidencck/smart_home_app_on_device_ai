import asyncio
from datetime import datetime, timedelta, timezone
from sqlalchemy import update
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import AsyncSessionLocal
from app.models.device import Device
from app.core.logger import logger

async def check_offline_devices():
    """
    检查超过 3 分钟未上报心跳的设备，将其状态置为离线。
    """
    try:
        async with AsyncSessionLocal() as session:
            # 当前时间减去 3 分钟
            threshold_time = datetime.now(timezone.utc) - timedelta(minutes=3)
            
            stmt = (
                update(Device)
                .where(
                    Device.is_online == True,
                    Device.last_seen < threshold_time
                )
                .values(is_online=False)
            )
            result = await session.execute(stmt)
            await session.commit()
            
            if result.rowcount > 0:
                logger.info(f"Marked {result.rowcount} devices as offline.")
    except Exception as e:
        logger.error(f"Error checking offline devices: {e}")

async def start_offline_worker():
    """
    后台任务循环，每分钟执行一次
    """
    logger.info("Starting offline device worker...")
    try:
        while True:
            await check_offline_devices()
            await asyncio.sleep(60)
    except asyncio.CancelledError:
        logger.info("Offline worker gracefully stopped.")
