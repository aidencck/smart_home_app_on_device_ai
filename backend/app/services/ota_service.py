from app.schemas.ota import OTACheckRequest, OTACheckResponse
from app.core.logger import logger

class OTAService:
    @staticmethod
    async def check_update(request: OTACheckRequest) -> OTACheckResponse:
        """
        处理端侧模型 OTA 检查请求
        """
        logger.info(f"Checking OTA for App Version: {request.app_version_code}, RAM: {request.ram_gb}GB")
        
        # 1. 硬件资源过滤规则
        if request.ram_gb < 3.0:
            # 对于低内存设备，直接拒绝下发端侧模型，强制走云端
            logger.info("Device RAM < 3GB, forcing cloud-only mode.")
            return OTACheckResponse(has_update=False)
            
        # 2. 模拟查库逻辑 (实际应查询 PostgreSQL 中的 OTA 策略表)
        target_model_version = "qwen-1.5b-q4_k_m-v2"
        target_min_app_version = 10  # 该模型要求 App 版本必须大于等于 10
        
        if request.app_version_code < target_min_app_version:
            logger.warning(f"App version {request.app_version_code} is too old for model {target_model_version}")
            return OTACheckResponse(has_update=False)
            
        if request.current_model_version == target_model_version:
            return OTACheckResponse(has_update=False)
            
        # 3. 构造下发响应
        # 实际生产中这里应调用云存储(OSS/S3)的 SDK 生成带过期时间的 Presigned URL
        mock_download_url = f"https://cdn.smarthome.com/models/{target_model_version}.gguf?sig=mock_signature"
        
        return OTACheckResponse(
            has_update=True,
            model_version=target_model_version,
            download_url=mock_download_url,
            md5_checksum="d41d8cd98f00b204e9800998ecf8427e",
            is_force_update=False
        )
