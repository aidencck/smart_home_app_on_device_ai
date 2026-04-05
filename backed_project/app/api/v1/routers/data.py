from fastapi import APIRouter, BackgroundTasks
from app.schemas.base import BaseResponse
from app.schemas.data import TelemetryLog
from app.services.data_service import DataFlywheelService

router = APIRouter()

@router.post("/telemetry", response_model=BaseResponse)
async def telemetry_upload(log_data: TelemetryLog, background_tasks: BackgroundTasks):
    """
    数据飞轮遥测上传接口
    
    接收端侧 Opt-in 的脱敏日志，通过 FastAPI BackgroundTasks 异步处理清洗。
    """
    background_tasks.add_task(DataFlywheelService.process_telemetry, log_data)
    
    return BaseResponse.success(
        data={"status": "queued"},
        message="Telemetry accepted and queued"
    )
