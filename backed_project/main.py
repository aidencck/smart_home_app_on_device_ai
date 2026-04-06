import os
from fastapi import FastAPI, Request, Response
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from contextlib import asynccontextmanager
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

from app.core.config import settings
from app.core.logger import setup_logging, logger
from app.core.exceptions import AppException, app_exception_handler, global_exception_handler, validation_exception_handler
from app.db.redis import init_redis, close_redis
import asyncio
from app.tasks.offline_worker import start_offline_worker

# AI Backend Routers
from app.api.v1.routers import ai, ota, data, devices, home, automations

# Placeholder for IoT Core Backend Routers (app/api/v1/endpoints/...)
try:
    from app.api.v1.endpoints.admin import users as admin_users, products as admin_products
except ImportError:
    admin_users = None
    admin_products = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup execution
    setup_logging()
    service_role = os.getenv("SERVICE_ROLE", "all")
    logger.info(f"Starting up SmartHome Backend... Role: {service_role}")
    await init_redis()
    logger.info("Redis initialized.")
    
    # Start background task for offline devices
    offline_worker_task = asyncio.create_task(start_offline_worker())
    logger.info("Background tasks started.")
    
    yield
    
    # Shutdown execution
    offline_worker_task.cancel()
    try:
        await offline_worker_task
    except asyncio.CancelledError:
        pass
    
    logger.info(f"Shutting down SmartHome Backend... Role: {service_role}")
    await close_redis()
    logger.info("Redis connection closed.")

app = FastAPI(
    title=f"{settings.PROJECT_NAME} - {os.getenv('SERVICE_ROLE', 'all').upper()}", 
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
from app.core.middleware import RequestLogMiddleware
app.add_middleware(RequestLogMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dynamic Router Loading for Microservice Isolation
service_role = os.getenv("SERVICE_ROLE", "all").lower()

if service_role in ["all", "ai_gateway"]:
    app.include_router(ai.router, prefix=f"{settings.API_V1_STR}/ai", tags=["AI Routing"])
    app.include_router(automations.router, prefix=f"{settings.API_V1_STR}/automations", tags=["Automations"])

if service_role in ["all", "device_shadow"]:
    app.include_router(devices.router, prefix=f"{settings.API_V1_STR}/devices", tags=["Device Shadow"])

if service_role in ["all", "data_flywheel"]:
    app.include_router(ota.router, prefix=f"{settings.API_V1_STR}/ota", tags=["Model OTA"])
    app.include_router(data.router, prefix=f"{settings.API_V1_STR}/data", tags=["Data Flywheel"])

if service_role in ["all", "iot_core", "device_shadow"]:
    app.include_router(home.router, prefix=f"{settings.API_V1_STR}/home", tags=["Home Overview"])

if service_role in ["all", "iot_core"] and admin_users and admin_products:
    app.include_router(admin_users.router, prefix=f"{settings.API_V1_STR}/admin/users", tags=["Admin Users"])
    app.include_router(admin_products.router, prefix=f"{settings.API_V1_STR}/admin/products", tags=["Admin Products"])

@app.get("/health", tags=["Health"])
async def health_check():
    """
    Check if the API and connections are healthy.
    """
    return {"status": "healthy", "version": settings.VERSION, "role": service_role}

@app.get("/metrics", tags=["Metrics"])
async def metrics():
    """
    Expose Prometheus metrics.
    """
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

# Mount static files for admin dashboard
app.mount("/static", StaticFiles(directory="static"), name="static")
