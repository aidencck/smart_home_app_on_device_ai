from typing import AsyncGenerator
from app.db.session import AsyncSessionLocal
from app.db import redis
from redis.asyncio import Redis

async def get_db() -> AsyncGenerator:
    """
    Dependency function that yields db sessions
    """
    async with AsyncSessionLocal() as session:
        yield session

async def get_redis() -> AsyncGenerator[Redis, None]:
    """
    Dependency function that yields redis client
    """
    yield redis.redis_client
