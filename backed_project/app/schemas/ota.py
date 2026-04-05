from pydantic import Field
from typing import Optional
from app.schemas.base import BaseSchema

class OTACheckRequest(BaseSchema):
    """端侧发起模型 OTA 检查的请求"""
    app_version_code: int = Field(..., description="端侧 Flutter App 的构建版本号")
    ram_gb: float = Field(..., description="端侧设备的物理内存大小(GB)")
    current_model_version: Optional[str] = Field(None, description="端侧当前加载的 GGUF 模型版本号")

class OTACheckResponse(BaseSchema):
    """OTA 检查的响应结构"""
    has_update: bool = Field(..., description="是否有可用更新")
    model_version: Optional[str] = Field(None, description="新模型版本号")
    download_url: Optional[str] = Field(None, description="CDN 预签名下载链接")
    md5_checksum: Optional[str] = Field(None, description="用于校验完整性的 MD5")
    is_force_update: bool = Field(False, description="是否强制更新（如旧版模型出现严重幻觉）")
