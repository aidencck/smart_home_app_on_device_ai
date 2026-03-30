from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

# Create Async Engine
engine = create_async_engine(
    settings.SQLALCHEMY_DATABASE_URI,
    echo=False,
    future=True,
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,
)

# Create Session Local
AsyncSessionLocal = async_sessionmaker(
    bind=engine, 
    class_=AsyncSession, 
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)
