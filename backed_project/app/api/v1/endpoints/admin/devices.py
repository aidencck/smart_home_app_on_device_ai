import secrets
import string
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel

from app.schemas.device import DeviceCreate, DeviceUpdate
from app.schemas.device import Device as DeviceResponse
from app.api import deps
from app.db.session import get_db
from app.models.device import Device
from app.models.product import Product
from app.models.user import User

router = APIRouter()

def generate_device_secret(length: int = 16) -> str:
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for i in range(length))

class RPCRequest(BaseModel):
    method: str
    params: dict = {}

@router.post("/rpc")
async def device_rpc(
    rpc_req: RPCRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Unified JSON-RPC style interface for Device CRUD operations.
    Methods: 'device.list', 'device.create', 'device.get', 'device.update', 'device.delete'
    """
    method = rpc_req.method
    params = rpc_req.params
    tenant_id = getattr(request.state, "tenant_id", None) if request else None

    if method == "device.list":
        skip = params.get("skip", 0)
        limit = params.get("limit", 100)
        product_id = params.get("product_id")
        
        stmt = select(Device)
        if tenant_id is not None:
            stmt = stmt.filter(Device.tenant_id == tenant_id)
        if product_id is not None:
            stmt = stmt.filter(Device.product_id == product_id)

        result = await db.execute(stmt.offset(skip).limit(limit))
        return {"data": result.scalars().all()}

    elif method == "device.create":
        device_in = DeviceCreate(**params)
        stmt = select(Product).filter(Product.id == device_in.product_id)
        if tenant_id is not None:
            stmt = stmt.filter(Product.tenant_id == tenant_id)
            
        result = await db.execute(stmt)
        if not result.scalars().first():
            raise HTTPException(status_code=404, detail="Product not found or access denied")

        stmt_dup = select(Device).filter(Device.device_name == device_in.device_name)
        result_dup = await db.execute(stmt_dup)
        if result_dup.scalars().first():
            raise HTTPException(status_code=400, detail="Device name already registered")

        if tenant_id is not None:
            from app.models.tenant import Tenant
            from sqlalchemy import func
            tenant_stmt = select(Tenant).filter(Tenant.id == tenant_id)
            tenant_result = await db.execute(tenant_stmt)
            tenant = tenant_result.scalars().first()
            if tenant:
                count_stmt = select(func.count(Device.id)).filter(Device.tenant_id == tenant_id, Device.is_deleted == False)
                count_result = await db.execute(count_stmt)
                if count_result.scalar() >= tenant.max_devices:
                    raise HTTPException(status_code=403, detail="Tenant quota exceeded.")

        create_data = device_in.model_dump()
        if not create_data.get("secret"):
            create_data["secret"] = generate_device_secret()
        if tenant_id is not None:
            create_data["tenant_id"] = tenant_id

        db_obj = Device(**create_data)
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return {"data": db_obj}

    elif method == "device.get":
        device_id = params.get("device_id")
        stmt = select(Device).filter(Device.id == device_id, Device.is_deleted == False)
        if tenant_id is not None:
            stmt = stmt.filter(Device.tenant_id == tenant_id)
            
        result = await db.execute(stmt)
        device = result.scalars().first()
        if not device:
            raise HTTPException(status_code=404, detail="Device not found")
        return {"data": device}

    elif method == "device.update":
        device_id = params.get("device_id")
        device_in = DeviceUpdate(**params.get("update_data", {}))
        stmt = select(Device).filter(Device.id == device_id, Device.is_deleted == False)
        if tenant_id is not None:
            stmt = stmt.filter(Device.tenant_id == tenant_id)
            
        result = await db.execute(stmt)
        device = result.scalars().first()
        if not device:
            raise HTTPException(status_code=404, detail="Device not found")

        for field, value in device_in.model_dump(exclude_unset=True).items():
            setattr(device, field, value)

        db.add(device)
        await db.commit()
        await db.refresh(device)
        return {"data": device}

    elif method == "device.delete":
        device_id = params.get("device_id")
        stmt = select(Device).filter(Device.id == device_id)
        if tenant_id is not None:
            stmt = stmt.filter(Device.tenant_id == tenant_id)
            
        result = await db.execute(stmt)
        device = result.scalars().first()
        if not device:
            raise HTTPException(status_code=404, detail="Device not found")

        device.is_deleted = True
        db.add(device)
        await db.commit()
        return {"data": device}

    else:
        raise HTTPException(status_code=400, detail=f"Method {method} not supported")
