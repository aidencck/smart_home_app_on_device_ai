import os
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "SmartHome Edge-Cloud API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["*"]
    
    # Database
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_DB: str = "smarthome_db"
    POSTGRES_PORT: str = "5432"
    
    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        return f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
    
    # Redis
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_PASSWORD: Optional[str] = None
    REDIS_DB: int = 0
    
    @property
    def REDIS_URI(self) -> str:
        auth = f":{self.REDIS_PASSWORD}@" if self.REDIS_PASSWORD else ""
        return f"redis://{auth}{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"
    
    # Security
    SECRET_KEY: str = "super-secret-key-change-me-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days
    
    # AI Fallback (OpenAI / vLLM)
    AI_API_KEY: str = "sk-placeholder-key"
    AI_API_BASE: str = "https://api.openai.com/v1"
    AI_MODEL_NAME: str = "gpt-4o-mini"
    
    # Celery & RabbitMQ
    RABBITMQ_URL: str = "amqp://guest:guest@rabbitmq:5672//"
    
    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True, extra="ignore")

settings = Settings()
