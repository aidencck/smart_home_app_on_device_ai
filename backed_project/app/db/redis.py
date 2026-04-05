import redis.asyncio as redis
from app.core.config import settings

redis_client = None

async def init_redis():
    global redis_client
    redis_client = redis.from_url(
        settings.REDIS_URI, 
        encoding="utf-8", 
        decode_responses=True,
        max_connections=10
    )

async def close_redis():
    global redis_client
    if redis_client:
        await redis_client.aclose()
