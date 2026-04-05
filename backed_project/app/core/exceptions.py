from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from typing import Any, Dict, Optional
from app.core.logger import logger
from enum import Enum

class ErrorCode(int, Enum):
    """
    统一业务错误码字典 (Business Error Codes)
    10xx: 用户/权限相关错误
    20xx: 业务逻辑错误
    30xx: 外部依赖/设备相关错误
    """
    # 通用错误
    BAD_REQUEST = 400
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404
    CONFLICT = 409
    INTERNAL_SERVER_ERROR = 500
    
    # 业务特有错误
    USER_NOT_EXIST = 1001
    PASSWORD_ERROR = 1002
    TOKEN_EXPIRED = 1003
    
    DEVICE_OFFLINE = 3001
    DEVICE_TIMEOUT = 3002
    STATE_STALE = 3003 # 状态过期 (Vector Clock mismatch)
    AI_RATE_LIMIT = 3004

class AppException(Exception):
    def __init__(
        self, 
        code: ErrorCode | int = ErrorCode.BAD_REQUEST, 
        message: str = "Bad Request", 
        data: Optional[Any] = None
    ):
        # 兼容直接传入 int 或 Enum
        self.code = code.value if isinstance(code, ErrorCode) else code
        self.message = message
        self.data = data

async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
    logger.warning(f"Business Exception [{exc.code}]: {exc.message} | Path: {request.url.path}")
    
    # HTTP 状态码映射：如果业务码是标准 HTTP 码则使用，否则统一返回 200 (或 400)，通过 body 里的 code 判断
    http_status = exc.code if exc.code >= 400 and exc.code < 600 else 200
    
    return JSONResponse(
        status_code=http_status,
        content={
            "code": exc.code,
            "message": exc.message,
            "data": exc.data,
        }
    )

async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """拦截 Pydantic 校验错误，转为统一结构"""
    errors = exc.errors()
    # 提取并拼装具体的校验错误字段和提示
    error_msgs = [f"{' -> '.join(map(str, err.get('loc', [])))}: {err.get('msg')}" for err in errors]
    message = "参数校验失败: " + "; ".join(error_msgs)
    
    logger.warning(f"Validation Exception: {message} | Path: {request.url.path}")
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "code": status.HTTP_422_UNPROCESSABLE_ENTITY,
            "message": message,
            "data": None,
        }
    )

async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.error(f"Global unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "code": ErrorCode.INTERNAL_SERVER_ERROR.value,
            "message": "服务器内部错误，请稍后再试",
            "data": None,
        }
    )
