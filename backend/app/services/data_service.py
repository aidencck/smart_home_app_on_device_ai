from app.schemas.data import TelemetryLog
from app.worker.tasks import process_telemetry_log
from app.core.logger import logger

class DataFlywheelService:
    @staticmethod
    async def enqueue_telemetry(log_data: TelemetryLog) -> str:
        """
        接收端侧遥测数据并推入 RabbitMQ 队列，实现极速返回
        """
        try:
            # 异步非阻塞推入 Celery 队列
            task = process_telemetry_log.delay(log_data.model_dump_json())
            logger.info(f"Enqueued telemetry log. Task ID: {task.id}")
            return task.id
        except Exception as e:
            logger.error(f"Failed to enqueue telemetry log: {e}")
            # 即使推入失败，也不阻断端侧，仅记录日志
            return ""
