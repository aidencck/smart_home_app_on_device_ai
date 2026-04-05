from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.api import deps
from app.db.session import get_db
from app.models.user import User
from app.schemas.user import User as UserSchema
from app.services.user_service import user_service

router = APIRouter()

@router.get("/", response_model=List[UserSchema])
async def read_users(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Retrieve users. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    # If platform admin (tenant_id is None), get all.
    # If B-end admin (tenant_id is not None), only get users belonging to this tenant.
    
    from sqlalchemy.future import select
    stmt = select(User)
    if tenant_id is not None:
        stmt = stmt.filter(User.tenant_id == tenant_id)
        
    stmt = stmt.offset(skip).limit(limit)
    result = await db.execute(stmt)
    users = result.scalars().all()
    
    return users

@router.put("/{user_id}/status", response_model=UserSchema)
async def update_user_status(
    *,
    db: AsyncSession = Depends(get_db),
    user_id: int,
    is_active: bool,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Update a user's active status. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    from sqlalchemy.future import select
    stmt = select(User).filter(User.id == user_id)
    if tenant_id is not None:
        stmt = stmt.filter(User.tenant_id == tenant_id)
        
    result = await db.execute(stmt)
    user = result.scalars().first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Do not allow admin to disable themselves
    if user.id == current_user.id and not is_active:
        raise HTTPException(status_code=400, detail="Cannot disable your own account")

    user = await user_service.update(db, db_obj=user, obj_in={"is_active": is_active})
    return user

@router.delete("/{user_id}", response_model=UserSchema)
async def delete_user(
    *,
    db: AsyncSession = Depends(get_db),
    user_id: int,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Delete a user. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    from sqlalchemy.future import select
    stmt = select(User).filter(User.id == user_id)
    if tenant_id is not None:
        stmt = stmt.filter(User.tenant_id == tenant_id)
        
    result = await db.execute(stmt)
    user = result.scalars().first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.id == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot delete your own account")

    await db.delete(user)
    await db.commit()
    return user
