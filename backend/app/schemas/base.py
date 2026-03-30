from pydantic import BaseModel, ConfigDict, Field
from typing import Any, Optional, Generic, TypeVar

# 定义泛型数据类型
T = TypeVar("T")

class BaseSchema(BaseModel):
    """所有 Pydantic Schema 的基类，配置了 ORM 映射和别名填充"""
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

class BaseResponse(BaseModel, Generic[T]):
    """
    核心公共组件：统一的 API 响应结构
    注意：此基类严禁随意修改字段！如果业务需要额外字段（如 pagination），请通过继承扩展。
    """
    code: int = Field(default=200, description="业务状态码，200 表示成功")
    message: str = Field(default="Success", description="响应提示信息")
    data: Optional[T] = Field(default=None, description="实际响应的业务数据")
    
    @classmethod
    def success(cls, data: Optional[T] = None, message: str = "Success") -> "BaseResponse[T]":
        return cls(code=200, message=message, data=data)

# 面向对象扩展示例：其他团队如果需要分页，不应该去修改上面的 BaseResponse
# 而是继承并扩展自己的 PaginationResponse
class PaginationResponse(BaseResponse[T], Generic[T]):
    total: int = Field(default=0, description="总条数")
    page: int = Field(default=1, description="当前页码")
    size: int = Field(default=20, description="每页条数")
    
    @classmethod
    def success_page(cls, data: T, total: int, page: int = 1, size: int = 20, message: str = "Success"):
        return cls(code=200, message=message, data=data, total=total, page=page, size=size)

