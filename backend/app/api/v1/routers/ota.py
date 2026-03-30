from fastapi import APIRouter
from app.schemas.base import BaseResponse
from app.schemas.ota import OTACheckRequest, OTACheckResponse
from app.services.ota_service import OTAService

router = APIRouter()

@router.post("/check", response_model=BaseResponse[OTACheckResponse])
async def check_update(request: OTACheckRequest):
    """
    端侧模型 OTA 检查接口
    
    1. 根据端侧 RAM 判断是否允许下发端侧模型
    2. 根据 App 版本号 (version_code) 校验与模型格式的兼容性
    3. 返回模型 CDN 下载链接与校验和
    """
    response_data = await OTAService.check_update(request)
    
    return BaseResponse.success(
        data=response_data,
        message="OTA check completed"
    )
