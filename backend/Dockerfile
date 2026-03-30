# 基于官方 Python 3.11 镜像构建 (使用高可用 GitHub Proxy 镜像)
FROM docker.m.daocloud.io/library/python:3.11-slim-bookworm

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    TZ=Asia/Shanghai

# 设置工作目录
WORKDIR /app

# 替换 apt 源为阿里云，加速系统依赖安装
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources

# 安装系统级依赖 (如 psycopg2/asyncpg 编译所需)
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 复制依赖文件并安装 (使用阿里云 pip 源)
COPY requirements.txt .
RUN pip install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/ \
    && pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/

# 复制项目代码
COPY . .

# 暴露端口
EXPOSE 8000

# 启动命令 (开发环境使用 reload 模式，生产环境应通过 docker-compose command 覆盖)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
