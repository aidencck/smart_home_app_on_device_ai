from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app import schemas
from app.api import deps
from app.db.session import get_db
from app.models.firmware import Firmware
from app.models.product import Product
from app.core.translation import _

router = APIRouter()

@router.post("/", response_model=schemas.Firmware)
async def create_firmware(
    *,
    db: AsyncSession = Depends(get_db),
    firmware_in: schemas.FirmwareCreate,
    current_user: schemas.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Upload/Register new firmware. (Admin only)
    """
    # Check product
    result = await db.execute(select(Product).filter(Product.id == firmware_in.product_id))
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail=_("product_not_found"))

    # Check version conflict
    result = await db.execute(select(Firmware).filter(
        Firmware.product_id == firmware_in.product_id, 
        Firmware.version == firmware_in.version
    ))
    if result.scalars().first():
        raise HTTPException(status_code=400, detail=_("firmware_exists"))

    db_obj = Firmware(
        version=firmware_in.version,
        product_id=firmware_in.product_id,
        file_url=str(firmware_in.file_url),
        file_hash=firmware_in.file_hash,
        description=firmware_in.description
    )
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj

@router.get("/", response_model=List[schemas.Firmware])
async def read_firmwares(
    db: AsyncSession = Depends(get_db),
    product_id: int | None = None,
    skip: int = 0,
    limit: int = 100,
    current_user: schemas.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Retrieve firmwares. (Admin only)
    """
    query = select(Firmware).offset(skip).limit(limit)
    if product_id:
        query = query.filter(Firmware.product_id == product_id)
        
    result = await db.execute(query)
    firmwares = result.scalars().all()
    return firmwares
