from typing import AsyncGenerator
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.db.session import AsyncSessionLocal
from app.db import redis
from redis.asyncio import Redis

security = HTTPBearer()

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

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Dependency function to validate JWT token and return current user context
    """
    token = credentials.credentials
    # FIXME: In a real implementation, you would decode the JWT here
    # e.g., payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    # For now, we simulate a simple check to prevent unauthenticated access.
    if not token or token == "invalid_token":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Mocking user context returned after validation
    return {"user_id": "simulated_user_id", "home_id": "simulated_home_id"}
