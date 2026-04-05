from datetime import datetime, timedelta
from typing import Any, Dict, List

from fastapi import APIRouter, Depends
from sqlalchemy import func, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.api import deps
from app.api.deps import get_db
from app.models.device import Device
from app.models.product import Product
from app.models.rule import Rule
from app.models.rule_log import RuleLog
from app.models.user import User

router = APIRouter()

@router.get("/overview", response_model=Dict[str, Any])
async def get_dashboard_overview(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_tenant_admin),
) -> Any:
    """
    Get high-level dashboard metrics:
    - Total Users
    - Total Devices (Online/Offline)
    - Active Rules
    - Total Products
    """
    # Filter by tenant if applicable
    tenant_id = current_user.tenant_id
    
    # 1. User Count
    user_query = select(func.count(User.id))
    if tenant_id:
        user_query = user_query.where(User.tenant_id == tenant_id)
    total_users = (await db.execute(user_query)).scalar() or 0
    
    # 2. Device Stats
    device_query = select(func.count(Device.id))
    online_query = select(func.count(Device.id)).where(Device.is_online == True)
    
    if tenant_id:
        device_query = device_query.where(Device.tenant_id == tenant_id)
        online_query = online_query.where(Device.tenant_id == tenant_id)
        
    total_devices = (await db.execute(device_query)).scalar() or 0
    online_devices = (await db.execute(online_query)).scalar() or 0
    offline_devices = total_devices - online_devices
    
    # 3. Rule Stats
    rule_query = select(func.count(Rule.id)).where(Rule.is_active == True)
    if tenant_id:
        rule_query = rule_query.join(User).where(User.tenant_id == tenant_id)
    active_rules = (await db.execute(rule_query)).scalar() or 0

    # 4. Product Stats
    product_query = select(func.count(Product.id))
    if tenant_id:
        product_query = product_query.where(Product.tenant_id == tenant_id)
    total_products = (await db.execute(product_query)).scalar() or 0
    
    return {
        "users": total_users,
        "devices": {
            "total": total_devices,
            "online": online_devices,
            "offline": offline_devices,
            "online_rate": round((online_devices / total_devices * 100), 2) if total_devices > 0 else 0
        },
        "rules": {
            "active": active_rules
        },
        "products": {
            "total": total_products
        }
    }

@router.get("/trends/users", response_model=Dict[str, Any])
async def get_user_trends(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_tenant_admin),
) -> Any:
    """
    Get user registration trends for the last 30 days.
    """
    tenant_id = current_user.tenant_id
    start_date = datetime.utcnow() - timedelta(days=30)
    
    query = (
        select(func.date(User.created_at).label("date"), func.count(User.id))
        .where(User.created_at >= start_date)
    )
    
    if tenant_id:
        query = query.where(User.tenant_id == tenant_id)
        
    query = query.group_by(text("date")).order_by(text("date"))
    
    result = await db.execute(query)
    data = [{"date": str(row[0]), "count": row[1]} for row in result.all()]
    return {"data": data}

@router.get("/trends/rules", response_model=Dict[str, Any])
async def get_rule_trends(
    skip: int = 0,
    limit: int = 10,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_tenant_admin),
) -> Any:
    """
    Get top triggered rules with pagination and total count.
    """
    tenant_id = current_user.tenant_id
    
    # 1. Get total count
    count_query = select(func.count(Rule.id))
    if tenant_id:
        count_query = count_query.join(User, Rule.user_id == User.id).where(User.tenant_id == tenant_id)
    total = (await db.execute(count_query)).scalar() or 0
    
    # 2. Get paginated data
    query = select(Rule).order_by(Rule.triggered_count.desc()).offset(skip).limit(limit)
    
    if tenant_id:
        query = query.join(User, Rule.user_id == User.id).where(User.tenant_id == tenant_id)
        
    result = await db.execute(query)
    rules = result.scalars().all()
    
    return {
        "total": total,
        "data": [
            {
                "id": r.id,
                "name": r.name,
                "count": r.triggered_count,
                "last_triggered": r.last_triggered_at
            }
            for r in rules
        ]
    }

@router.get("/logs/rules", response_model=Dict[str, Any])
async def get_rule_logs(
    skip: int = 0,
    limit: int = 10,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_tenant_admin),
) -> Any:
    """
    Get recent rule execution logs with pagination.
    """
    tenant_id = current_user.tenant_id
    
    # 1. Get total count
    count_query = select(func.count(RuleLog.id)).join(Rule, RuleLog.rule_id == Rule.id)
    if tenant_id:
        count_query = count_query.join(User, Rule.user_id == User.id).where(User.tenant_id == tenant_id)
    total = (await db.execute(count_query)).scalar() or 0

    # 2. Get paginated data
    query = (
        select(RuleLog, Rule.name)
        .join(Rule, RuleLog.rule_id == Rule.id)
    )
    
    if tenant_id:
        query = query.join(User, Rule.user_id == User.id).where(User.tenant_id == tenant_id)
        
    query = query.order_by(RuleLog.triggered_at.desc()).offset(skip).limit(limit)
    
    result = await db.execute(query)
    
    logs = []
    for row in result.all():
        log, rule_name = row
        logs.append({
            "id": log.id,
            "rule_name": rule_name,
            "device_name": log.device_name,
            "triggered_at": log.triggered_at,
            "result": log.result,
            "details": log.details
        })
        
    return {"total": total, "data": logs}
