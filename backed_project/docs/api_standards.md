# API 接口规范与异常处理复用指南

为了保证前后端及端云协同交互的数据一致性，后端项目强制采用统一的响应数据结构与异常抛出机制。本指南说明了相关组件的设计与复用方法。

## 1. 统一响应结构 (`BaseResponse`)

所有的 API 路由接口都**不应该**直接返回裸字典（如 `{"status": "ok"}`）。必须使用 `app.schemas.base.BaseResponse` 泛型模型进行包装。

### 结构定义
```json
{
  "code": 200,          // 业务状态码，200 为成功，其他为业务错误
  "message": "Success", // 提示信息
  "data": { ... }       // 具体的业务数据负载 (泛型 T)
}
```

### 路由复用示例
在 Router 中，通过指定 `response_model=BaseResponse[YourSchema]` 让 FastAPI 自动生成正确的 Swagger 结构，并通过 `BaseResponse.success()` 快速返回：

```python
from fastapi import APIRouter
from app.schemas.base import BaseResponse

router = APIRouter()

@router.post("/chat", response_model=BaseResponse[dict])
async def cloud_ai_fallback():
    # 业务逻辑...
    return BaseResponse.success(data={"intent": "turn_on_light"}, message="解析成功")
```

## 2. 全局异常与错误码机制 (`AppException` & `ErrorCode`)

为了避免在 Service 层或 Router 层中硬编码 HTTP 状态码，系统采用**抛出异常即响应**的机制 (`Throw as Return`)。

### 核心组件
位于 `app/core/exceptions.py`：
- **`ErrorCode` (Enum)**：定义了所有的业务错误码枚举。例如 `10xx` 代表用户级错误，`30xx` 代表设备级错误。
- **`AppException`**：自定义异常类。在业务中遇到不符合预期的逻辑时直接 `raise`。
- **全局拦截器**：`main.py` 中已经挂载了拦截器。当捕获到 `AppException` 时，会自动将拦截的错误码和信息转换为统一的 JSON 结构并返回给客户端。

### 业务层复用示例
在 Service 层处理逻辑时，如果发现设备影子过期，直接抛出异常，无需关心如何构造 Response：

```python
from app.core.exceptions import AppException, ErrorCode

async def update_device_status(vector_clock: int):
    current_clock = get_current_clock()
    
    if vector_clock < current_clock:
        # 直接抛出，全局中间件会拦截并返回: {"code": 3003, "message": "设备状态已过期", "data": null}
        raise AppException(
            code=ErrorCode.STATE_STALE, 
            message="设备状态已过期，请重新同步"
        )
```

## 3. Pydantic 参数校验拦截
当客户端传入的数据不符合 Schema 定义时，FastAPI 原生会抛出 `RequestValidationError`。
我们已经在全局重写了该异常拦截器，将其转化为标准的结构返回：
```json
{
  "code": 422,
  "message": "参数校验失败: body -> device_id: field required",
  "data": null
}
```
这保证了无论是业务逻辑报错还是参数校验报错，客户端（Flutter/Isolate 端）都能使用一套通用的解析逻辑来处理。
