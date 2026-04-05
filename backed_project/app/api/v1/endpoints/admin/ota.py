from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel

from app.api import deps
from app.db.session import get_db
from app.models.ota import OTAJob, OTAExecution
from app.models.device import Device
from app.models.user import User

from loguru import logger

router = APIRouter()

class OTAJobCreate(BaseModel):
    product_id: int
    firmware_id: int
    target_version: str
    strategy: dict | None = None

class OTAJobResponse(BaseModel):
    id: int
    product_id: int
    firmware_id: int
    target_version: str
    status: str
    
    class Config:
        from_attributes = True

@router.post("/", response_model=OTAJobResponse)
async def create_ota_job(
    *,
    db: AsyncSession = Depends(get_db),
    job_in: OTAJobCreate,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Create a new OTA Job. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None

    # Verify Product belongs to tenant
    from app.models.product import Product
    stmt = select(Product).filter(Product.id == job_in.product_id)
    if tenant_id is not None:
        stmt = stmt.filter(Product.tenant_id == tenant_id)
    if not (await db.execute(stmt)).scalars().first():
        raise HTTPException(status_code=400, detail="Product not found or access denied")

    # Create Job
    job = OTAJob(
        tenant_id=tenant_id,
        product_id=job_in.product_id,
        firmware_id=job_in.firmware_id,
        target_version=job_in.target_version,
        strategy=job_in.strategy,
        status="pending"
    )
    db.add(job)
    await db.commit()
    await db.refresh(job)
    
    # Calculate target devices
    # Logic for Strategy:
    # 1. strategy={"type": "all"} -> All eligible devices
    # 2. strategy={"type": "gray", "percent": 10} -> Random 10% of eligible devices
    
    dev_stmt = select(Device).filter(
        Device.product_id == job_in.product_id,
        Device.is_deleted == False,
        (Device.firmware_version != job_in.target_version) | (Device.firmware_version == None)
    )
    if tenant_id is not None:
        dev_stmt = dev_stmt.filter(Device.tenant_id == tenant_id)
        
    devices = (await db.execute(dev_stmt)).scalars().all()
    
    # Apply strategy
    import random
    if job_in.strategy and job_in.strategy.get("type") == "gray":
        percent = job_in.strategy.get("percent", 100)
        # Ensure percent is valid
        if not (0 < percent <= 100):
            percent = 100
        
        target_count = int(len(devices) * (percent / 100.0))
        if target_count < 1 and len(devices) > 0:
            target_count = 1
            
        devices = random.sample(devices, target_count)
    
    for dev in devices:
        execution = OTAExecution(
            job_id=job.id,
            device_id=dev.id,
            status="queued"
        )
        db.add(execution)
        
    await db.commit()
    return job

@router.get("/", response_model=List[OTAJobResponse])
async def read_ota_jobs(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Retrieve OTA Jobs. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    stmt = select(OTAJob)
    if tenant_id is not None:
        stmt = stmt.filter(OTAJob.tenant_id == tenant_id)
        
    stmt = stmt.offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()

@router.post("/{job_id}/start")
async def start_ota_job(
    *,
    db: AsyncSession = Depends(get_db),
    job_id: int,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Start an OTA Job. Sends MQTT notification to all queued devices.
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    # Join Firmware to get download URL
    from app.models.firmware import Firmware
    job_stmt = select(OTAJob).join(Firmware).filter(OTAJob.id == job_id)
    if tenant_id is not None:
        job_stmt = job_stmt.filter(OTAJob.tenant_id == tenant_id)
    
    # We need to eager load firmware
    from sqlalchemy.orm import selectinload
    job_stmt = job_stmt.options(selectinload(OTAJob.firmware))
    
    job = (await db.execute(job_stmt)).scalars().first()
    if not job:
        raise HTTPException(status_code=404, detail="OTA Job not found")
        
    if job.status != "pending":
        raise HTTPException(status_code=400, detail="Job is not pending")
        
    job.status = "in_progress"
    db.add(job)
    
    # Update executions and notify via MQTT
    exec_stmt = select(OTAExecution).join(Device).filter(
        OTAExecution.job_id == job.id, 
        OTAExecution.status == "queued"
    ).options(selectinload(OTAExecution.device).selectinload(Device.product))
    
    executions = (await db.execute(exec_stmt)).scalars().all()
    
    from app.services.mqtt_service import mqtt_service
    import json
    
    notified_count = 0
    for ex in executions:
        ex.status = "notified"
        db.add(ex)
        
        # Publish MQTT message
        # Topic: sys/{product_key}/{device_name}/ota/inform
        device = ex.device
        if device and device.product:
            topic = f"sys/{device.product.product_key}/{device.device_name}/ota/inform"
            payload = {
                "job_id": job.id,
                "version": job.target_version,
                "url": job.firmware.file_url,
                "hash": job.firmware.file_hash,
                "size": 0, # TODO: add size to Firmware model
                "force": False
            }
            if mqtt_service.is_connected:
                await mqtt_service.client.publish(topic, payload)
                notified_count += 1
            else:
                logger.warning(f"MQTT not connected, failed to notify {device.device_name}")
        
    await db.commit()
    return {"status": "started", "devices_notified": notified_count}
