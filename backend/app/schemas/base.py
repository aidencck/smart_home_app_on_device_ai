from pydantic import BaseModel, ConfigDict, Field
from typing import Any, Optional, Generic, TypeVar

# 定义泛型数据类型
T = TypeVar("T")

class BaseSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

class BaseResponse(BaseModel, Generic[T]):
    """
    统一的 API 响应结构
    """
    code: int = Field(default=200, description="业务状态码，200 表示成功")
    message: str = Field(default="Success", description="响应提示信息")
    data: Optional[T] = Field(default=None, description="实际响应的业务数据")
    
    @classmethod
    def success(cls, data: Optional[T] = None, message: str = "Success") -> "BaseResponse[T]":
        return cls(code=200, message=message, data=data)

