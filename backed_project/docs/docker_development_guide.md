# 后端 Docker 容器化开发指南

为保证团队开发环境的绝对一致性，防止“在我的电脑上能跑”的经典问题，我们采用 Docker 与 Docker Compose 将 FastAPI 后端及其依赖（PostgreSQL、Redis）进行了全面容器化封装。

## 1. 架构与设计优势
- **环境隔离**：所有 Python 依赖 (通过 `requirements.txt`) 和系统依赖 (如编译 `asyncpg` 需要的 `gcc`) 均在 `Dockerfile` 中定义并在容器内安装，绝对不会污染您的宿主机开发环境。
- **一键拉起**：通过 `docker-compose.yml` 实现了 API 服务、数据库和缓存的协同编排，并配置了 `depends_on` 和 `healthcheck` 确保启动顺序正确。
- **热重载支持 (Hot Reload)**：我们在 `docker-compose.yml` 中将本地代码目录挂载 (`volumes: - .:/app`) 到了容器内部，配合 Uvicorn 的 `--reload` 参数，您在宿主机 IDE 中修改代码后，容器内的服务会自动重启。

## 2. 快速启动步骤

### 第一步：环境配置
将环境变量示例文件复制为实际生效的配置文件：
```bash
cp .env.example .env
```
*(注意：在本地开发时，`.env` 中的配置无需修改即可运行；但部署到生产服务器时，必须修改 `SECRET_KEY` 及数据库密码。)*

### 第二步：一键构建与启动
确保您的电脑已安装 Docker 和 Docker Compose。在 `backend/` 目录下执行：
```bash
docker-compose up -d --build
```
参数说明：
- `-d`: 在后台静默运行。
- `--build`: 强制重新构建镜像（当您修改了 `requirements.txt` 时必须带上此参数）。

### 第三步：验证服务状态
执行以下命令查看各容器状态：
```bash
docker-compose ps
```
如果一切正常，您应该能看到 `smarthome_api`, `smarthome_db`, `smarthome_redis` 三个容器均处于 `Up (healthy)` 状态。

现在您可以访问以下地址：
- **API 接口健康检查**: [http://localhost:8000/health](http://localhost:8000/health)
- **Swagger 交互式接口文档**: [http://localhost:8000/docs](http://localhost:8000/docs)

## 3. 常见开发操作指南

### 查看实时日志
当进行接口调试时，如果想查看 API 的实时日志（包含 Loguru 打印的信息与请求追踪 ID）：
```bash
docker-compose logs -f api
```

### 进入容器执行命令 (如 Alembic 迁移)
如果您需要执行数据库迁移脚本或进入容器的 Shell 环境：
```bash
# 进入 API 容器的 bash 环境
docker exec -it smarthome_api /bin/bash

# 在容器内执行 alembic 迁移 (假设已初始化)
alembic revision --autogenerate -m "init"
alembic upgrade head
```

### 停止与清理
当您结束开发时，可以通过以下命令停止服务：
```bash
# 仅停止容器，保留数据库和 Redis 的数据卷
docker-compose down

# 停止容器并销毁所有数据卷（警告：这会清空数据库和缓存中的所有数据！）
docker-compose down -v
```

## 4. 团队协同注意事项
1. **依赖变更**：如果引入了新的 Python 库，请先更新宿主机的 `requirements.txt`，然后务必通知团队成员执行 `docker-compose up -d --build` 重新构建镜像。
2. **.env 文件**：永远不要将包含真实敏感信息的 `.env` 文件提交到 Git 仓库，它已经被加入到了 `.gitignore` 和 `.dockerignore` 中。新增环境变量项时，请同步更新 `.env.example` 文件。
