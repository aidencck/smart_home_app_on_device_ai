from fastapi import APIRouter
from app.schemas.base import BaseResponse
from app.schemas.data import TelemetryLog
from app.services.data_service import DataFlywheelService

router = APIRouter()

@router.post("/telemetry", response_model=BaseResponse)
async def telemetry_upload(log_data: TelemetryLog):
    """
    数据飞轮遥测上传接口
    
    接收端侧 Opt-in 的脱敏日志，直接推入 RabbitMQ 队列供 Celery Worker 清洗。
    """
    task_id = await DataFlywheelService.enqueue_telemetry(log_data)
    
    return BaseResponse.success(
        data={"task_id": task_id},
        message="Telemetry accepted and queued"
    )
