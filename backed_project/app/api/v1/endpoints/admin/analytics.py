from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends
from sqlalchemy import func, select, text, desc, case
from sqlalchemy.ext.asyncio import AsyncSession

from app.api import deps
from app.api.deps import get_db
from app.models.tenant import Tenant
from app.models.user import User
from app.models.device import Device
from app.models.product import Product
from app.models.rule import Rule
from app.models.rule_log import RuleLog

router = APIRouter()

@router.get("/overview", response_model=Dict[str, Any])
async def get_analytics_overview(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    L1: North Star Metrics (Superuser Only)
    - Revenue (MRR/ARR)
    - Tenant Growth & Health
    - Device Scale
    """
    
    # 1. Tenants & Revenue (Business Health)
    total_tenants = (await db.execute(select(func.count(Tenant.id)))).scalar() or 0
    paid_tenants = (await db.execute(select(func.count(Tenant.id)).where(Tenant.plan_type != "free"))).scalar() or 0
    
    # Simple MRR Estimation: Enterprise=$299, Others=$0
    # In real world, this would come from Stripe/Billing
    estimated_mrr = paid_tenants * 299
    
    # 2. Devices (Scale)
    total_devices = (await db.execute(select(func.count(Device.id)))).scalar() or 0
    activated_devices = (await db.execute(select(func.count(Device.id)).where(Device.status != "unactivated"))).scalar() or 0
    online_devices = (await db.execute(select(func.count(Device.id)).where(Device.is_online == True))).scalar() or 0
    
    # 3. System Health (Stability)
    # Calculate % of devices online across platform
    system_health_score = round((online_devices / activated_devices * 100), 2) if activated_devices > 0 else 0
    
    # 4. Activity (Last 24h)
    yesterday = datetime.utcnow() - timedelta(days=1)
    new_users_24h = (await db.execute(select(func.count(User.id)).where(User.created_at >= yesterday))).scalar() or 0
    rule_executions_24h = (await db.execute(select(func.count(RuleLog.id)).where(RuleLog.triggered_at >= yesterday))).scalar() or 0
    
    return {
        "business": {
            "mrr": estimated_mrr,
            "arr": estimated_mrr * 12,
            "paid_tenants": paid_tenants,
            "total_tenants": total_tenants,
            "conversion_rate": round((paid_tenants / total_tenants * 100), 2) if total_tenants > 0 else 0
        },
        "scale": {
            "total_devices": total_devices,
            "active_devices": activated_devices,
            "devices_per_tenant": round(total_devices / total_tenants, 1) if total_tenants > 0 else 0
        },
        "health": {
            "system_uptime": 99.99, # Mocked for now
            "device_online_rate": system_health_score,
            "issues_24h": 0 # Placeholder for alert count
        },
        "activity": {
            "new_users_24h": new_users_24h,
            "rule_executions_24h": rule_executions_24h
        }
    }

@router.get("/tenants/growth", response_model=Dict[str, Any])
async def get_tenant_growth(
    days: int = 30,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Tenant growth trend
    """
    start_date = datetime.utcnow() - timedelta(days=days)
    
    query = (
        select(func.date(Tenant.created_at).label("date"), func.count(Tenant.id))
        .where(Tenant.created_at >= start_date)
        .group_by(text("date"))
        .order_by(text("date"))
    )
    
    result = await db.execute(query)
    data = [{"date": str(row[0]), "count": row[1]} for row in result.all()]
    return {"data": data}

@router.get("/devices/usage/top", response_model=Dict[str, Any])
async def get_top_active_devices(
    limit: int = 10,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Get devices with most telemetry activity (Last 7 days).
    Requires TimescaleDB Telemetry table.
    """
    from app.models.timescale.telemetry import Telemetry
    
    start_date = datetime.utcnow() - timedelta(days=7)
    
    # Aggregate telemetry counts by device
    query = (
        select(
            Telemetry.device_id, 
            func.count(Telemetry.id).label("count"),
            Device.name,
            Device.device_name,
            Tenant.name.label("tenant_name")
        )
        .join(Device, Telemetry.device_id == Device.id)
        .join(Tenant, Device.tenant_id == Tenant.id, isouter=True)
        .where(Telemetry.timestamp >= start_date)
        .group_by(Telemetry.device_id, Device.name, Device.device_name, Tenant.name)
        .order_by(desc("count"))
        .limit(limit)
    )
    
    try:
        result = await db.execute(query)
        data = [
            {
                "device_id": row.device_id,
                "name": row.name,
                "device_name": row.device_name,
                "tenant": row.tenant_name or "Unknown",
                "message_count": row.count
            }
            for row in result.all()
        ]
        return {"data": data}
    except Exception as e:
        # Fallback if Telemetry table not ready or empty
        return {"data": [], "error": str(e)}

@router.get("/devices/distribution", response_model=Dict[str, Any])
async def get_device_distribution(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_tenant_admin),
) -> Any:
    """
    Device distribution by Product
    """
    tenant_id = current_user.tenant_id
    
    query = (
        select(Product.name, func.count(Device.id))
        .join(Device, Device.product_id == Product.id)
    )
    
    if tenant_id:
        query = query.where(Product.tenant_id == tenant_id)
        
    query = query.group_by(Product.name)
    
    result = await db.execute(query)
    data = [{"name": row[0], "value": row[1]} for row in result.all()]
    return {"data": data}

@router.get("/automation/performance", response_model=Dict[str, Any])
async def get_automation_performance(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_tenant_admin),
) -> Any:
    """
    Rule execution success rate
    """
    tenant_id = current_user.tenant_id
    
    query = select(
        func.count(RuleLog.id).label("total"),
        func.sum(case((RuleLog.result == "success", 1), else_=0)).label("success")
    ).join(Rule, RuleLog.rule_id == Rule.id)
    
    if tenant_id:
        query = query.join(User, Rule.user_id == User.id).where(User.tenant_id == tenant_id)
        
    result = (await db.execute(query)).first()
    total = result.total or 0
    success = result.success or 0
    
    return {
        "total_executions": total,
        "success_count": success,
        "success_rate": round((success / total * 100), 2) if total > 0 else 0
    }
