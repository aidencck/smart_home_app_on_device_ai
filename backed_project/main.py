from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from contextlib import asynccontextmanager

from app.core.config import settings
from app.core.logger import setup_logging, logger
from app.core.exceptions import AppException, app_exception_handler, global_exception_handler, validation_exception_handler
from app.core.middleware import RequestLogMiddleware
from app.db.redis import init_redis, close_redis

# AI Backend Routers
from app.api.v1.routers import ai, ota, data, devices

# Placeholder for IoT Core Backend Routers (app/api/v1/endpoints/...)
# from core_app.api.v1.endpoints import users, products, firmwares

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup execution
    setup_logging()
    logger.info("Starting up SmartHome Backend...")
    await init_redis()
    logger.info("Redis initialized.")
    
    yield
    
    # Shutdown execution
    logger.info("Shutting down SmartHome Backend...")
    await close_redis()
    logger.info("Redis connection closed.")

app = FastAPI(
    title=settings.PROJECT_NAME, 
    version=settings.VERSION,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# Exception Handlers
app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, global_exception_handler)

# Middlewares
app.add_middleware(RequestLogMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- AI Backend Routers (from smarthome APP/smart_home_app/backend) ---
app.include_router(ai.router, prefix=f"{settings.API_V1_STR}/ai", tags=["AI Routing"])
app.include_router(ota.router, prefix=f"{settings.API_V1_STR}/ota", tags=["Model OTA"])
app.include_router(data.router, prefix=f"{settings.API_V1_STR}/data", tags=["Data Flywheel"])
app.include_router(devices.router, prefix=f"{settings.API_V1_STR}/devices", tags=["Device Shadow"])

# --- Core IoT Platform Routers (merged from /app) ---
# This merges the admin, users, and IoT routing directly into this unified FastAPI instance
from app.api.v1.endpoints.admin import users as admin_users, products as admin_products
app.include_router(admin_users.router, prefix=f"{settings.API_V1_STR}/admin/users", tags=["Admin Users"])
app.include_router(admin_products.router, prefix=f"{settings.API_V1_STR}/admin/products", tags=["Admin Products"])

@app.get("/health", tags=["Health"])
async def health_check():
    """
    Check if the API and connections are healthy.
    """
    return {"status": "healthy", "version": settings.VERSION}
