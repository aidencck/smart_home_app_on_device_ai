# 智能家居后端项目基建架构规划

为保证后续端云协同架构的高效开发与快速复用，我们对 FastAPI 后端项目进行了系统性的基建规划。本设计遵循高内聚低耦合原则，确保各模块职责单一，易于扩展和维护。

## 1. 目录结构规范
项目采用典型的领域驱动设计 (DDD) 与分层架构，基础目录结构如下：
```text
backend/
├── app/
│   ├── api/          # 接口层 (路由定义与控制器)
│   │   ├── deps/     # 依赖注入 (数据库、Redis、鉴权提取)
│   │   └── v1/       # 接口版本控制
│   ├── core/         # 核心层 (配置、异常、安全、中间件、日志)
│   ├── db/           # 数据库层 (连接池、会话管理、基础模型)
│   ├── models/       # 领域层 (SQLAlchemy 实体模型)
│   ├── schemas/      # 表现层 (Pydantic 数据验证模型)
│   ├── services/     # 业务逻辑层 (具体的业务服务与外部调用)
│   └── utils/        # 工具层 (通用帮助函数)
├── docs/             # 架构文档与说明
├── main.py           # FastAPI 主入口与生命周期管理
└── requirements.txt  # 核心依赖清单
```

## 2. 核心基建模块说明

### 2.1 核心配置管理 (`app/core/config.py`)
- **方案**: 采用 `pydantic-settings` 库实现强类型的配置管理。
- **职责**: 自动从环境变量和 `.env` 文件中加载配置（如数据库 URI、Redis 地址、JWT 密钥、AI 接口令牌等），并进行类型校验，避免由于缺少关键配置导致的线上故障。

### 2.2 异步数据库与会话管理 (`app/db/session.py`)
- **方案**: 使用 `SQLAlchemy 2.0` 的异步特性结合 `asyncpg` 驱动。
- **职责**:
  - 管理全应用唯一的异步引擎 (`AsyncEngine`)。
  - 创建异步会话工厂 (`async_sessionmaker`)。
  - `app/db/base.py` 提供声明式基类与统一表名生成策略。

### 2.3 缓存与设备影子存储 (`app/db/redis.py`)
- **方案**: 使用 `redis.asyncio` 库实现异步缓存。
- **职责**: 为端侧高频状态上报、Semantic Cache 提供毫秒级存储支持。统一封装 Redis 客户端的连接与销毁生命周期。

### 2.4 全局异常与日志处理 (`app/core/exceptions.py` & `logger.py`)
- **方案**: 自定义应用级异常 (`AppException`) 和标准化的 Python `logging` 配置。
- **职责**:
  - 提供统一的 HTTP 错误返回结构 (`{"code": xxx, "message": "xxx", "data": null}`)。
  - 拦截未捕获的全局异常并记录堆栈，隐藏敏感信息。
  - 日志自动切割，区分 `INFO`/`ERROR` 等级，并加入 Request ID 追踪。

### 2.5 依赖注入机制 (`app/api/deps.py`)
- **方案**: 利用 FastAPI 强大的 `Depends` 机制。
- **职责**: 
  - 动态注入异步数据库会话 (`get_db`)。
  - 动态注入 Redis 客户端 (`get_redis`)。
  - 提供 Token 解析与当前登录用户获取，将鉴权与业务解耦。

### 2.6 中间件基建 (`app/core/middleware.py`)
- **方案**: 基于 Starlette 的 `BaseHTTPMiddleware`。
- **职责**: 
  - 注入 `X-Request-ID`，用于链路追踪。
  - 记录每个请求的执行耗时 (`Process-Time`)。
  - 全局 CORS (跨域资源共享) 配置。

## 3. 生命周期管理 (`main.py`)
在 FastAPI 启动 (`startup`) 与关闭 (`shutdown`) 阶段（通过 `lifespan` 特性），统一管理数据库连接池的预热和释放、Redis 的连接与断开，确保系统平滑启动与安全下线。
