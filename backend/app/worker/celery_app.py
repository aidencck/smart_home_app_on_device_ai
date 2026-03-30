from celery import Celery
from app.core.config import settings

celery_app = Celery(
    "smarthome_worker",
    broker=settings.RABBITMQ_URL,
    backend=settings.REDIS_URI,
    include=["app.worker.tasks"]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="Asia/Shanghai",
    enable_utc=True,
    task_track_started=True,
    # 防止大任务拖垮 Worker
    worker_prefetch_multiplier=1,
)
