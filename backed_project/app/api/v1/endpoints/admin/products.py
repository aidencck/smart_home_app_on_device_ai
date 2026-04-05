from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.api import deps
from app.api.deps import get_db
from app.models.product import Product
from app.schemas.product import ProductCreate, ProductUpdate
from app.schemas.product import Product as ProductResponse
from app.models.user import User

router = APIRouter()

@router.get("/", response_model=List[ProductResponse])
async def read_products(
    db: AsyncSession = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Retrieve products.
    """
    # Enforce tenant isolation if tenant_id exists
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    stmt = select(Product)
    if tenant_id is not None:
        stmt = stmt.filter(Product.tenant_id == tenant_id)
        
    stmt = stmt.offset(skip).limit(limit)
    result = await db.execute(stmt)
    products = result.scalars().all()
    return products

@router.post("/", response_model=ProductResponse)
async def create_product(
    *,
    db: AsyncSession = Depends(get_db),
    product_in: ProductCreate,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Create new product. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None

    # Check if product_key exists
    stmt = select(Product).filter(Product.product_key == product_in.product_key)
    if tenant_id is not None:
        stmt = stmt.filter(Product.tenant_id == tenant_id)
        
    result = await db.execute(stmt)
    if result.scalars().first():
        raise HTTPException(status_code=400, detail="Product key already registered")

    db_obj = Product(
        tenant_id=tenant_id,
        name=product_in.name,
        description=product_in.description,
        product_key=product_in.product_key,
        is_active=product_in.is_active,
        thing_model=product_in.thing_model.model_dump() if product_in.thing_model else None
    )
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj

@router.post("/seed", response_model=List[ProductResponse])
async def seed_products(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Seed default products (Light, Vacuum, Desk)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    # Define Thing Models
    
    # 1. Smart Light
    tm_light = {
        "version": "1.0",
        "properties": [
            {"identifier": "power", "name": "Switch", "accessMode": "rw", "dataType": {"type": "bool"}},
            {"identifier": "brightness", "name": "Brightness", "accessMode": "rw", "dataType": {"type": "int", "min": 0, "max": 100, "unit": "%"}},
            {"identifier": "color_temp", "name": "Color Temperature", "accessMode": "rw", "dataType": {"type": "int", "min": 2700, "max": 6500, "unit": "K"}},
            {"identifier": "color", "name": "Color (RGB)", "accessMode": "rw", "dataType": {"type": "struct", "specs": [
                {"identifier": "r", "dataType": {"type": "int", "min": 0, "max": 255}},
                {"identifier": "g", "dataType": {"type": "int", "min": 0, "max": 255}},
                {"identifier": "b", "dataType": {"type": "int", "min": 0, "max": 255}}
            ]}}
        ]
    }
    
    # 2. Robot Vacuum
    tm_vacuum = {
        "version": "1.0",
        "properties": [
            {"identifier": "status", "name": "Status", "accessMode": "r", "dataType": {"type": "enum", "specs": {"idle": "Idle", "cleaning": "Cleaning", "charging": "Charging", "error": "Error"}}},
            {"identifier": "battery", "name": "Battery Level", "accessMode": "r", "dataType": {"type": "int", "min": 0, "max": 100, "unit": "%"}},
            {"identifier": "mode", "name": "Cleaning Mode", "accessMode": "rw", "dataType": {"type": "enum", "specs": {"standard": "Standard", "quiet": "Quiet", "turbo": "Turbo"}}}
        ],
        "services": [
            {"identifier": "start", "name": "Start Cleaning", "inputData": [], "outputData": []},
            {"identifier": "stop", "name": "Stop Cleaning", "inputData": [], "outputData": []},
            {"identifier": "return_to_base", "name": "Return to Base", "inputData": [], "outputData": []}
        ],
        "events": [
            {"identifier": "error", "name": "Error Occurred", "type": "alert", "outputData": [
                 {"identifier": "code", "name": "Error Code", "dataType": {"type": "int"}},
                 {"identifier": "message", "name": "Error Message", "dataType": {"type": "string"}}
            ]}
        ]
    }
    
    # 3. Standing Desk
    tm_desk = {
        "version": "1.0",
        "properties": [
             {"identifier": "height", "name": "Current Height", "accessMode": "r", "dataType": {"type": "float", "unit": "cm", "min": 60.0, "max": 120.0}},
             {"identifier": "target_height", "name": "Target Height", "accessMode": "rw", "dataType": {"type": "float", "unit": "cm", "min": 60.0, "max": 120.0}}
        ],
        "services": [
             {"identifier": "set_preset", "name": "Move to Preset", "inputData": [
                 {"identifier": "preset_index", "name": "Preset Index", "dataType": {"type": "int", "min": 1, "max": 4}}
             ]}
        ]
    }

    products_data = [
        {"name": "Smart Light Pro", "product_key": "light_pro_001", "thing_model": tm_light},
        {"name": "Robot Vacuum X1", "product_key": "vacuum_x1_001", "thing_model": tm_vacuum},
        {"name": "Ergo Desk S1", "product_key": "desk_s1_001", "thing_model": tm_desk},
    ]
    
    created_products = []
    for p_data in products_data:
        # Check if exists
        stmt = select(Product).filter(Product.product_key == p_data["product_key"])
        if tenant_id is not None:
            stmt = stmt.filter(Product.tenant_id == tenant_id)
            
        result = await db.execute(stmt)
        if not result.scalars().first():
            db_obj = Product(
                tenant_id=tenant_id,
                name=p_data["name"],
                product_key=p_data["product_key"],
                thing_model=p_data["thing_model"],
                is_active=True
            )
            db.add(db_obj)
            created_products.append(db_obj)
    
    if created_products:
        await db.commit()
        for p in created_products:
            await db.refresh(p)
            
    return created_products

@router.get("/{product_id}", response_model=ProductResponse)
async def read_product(
    *,
    db: AsyncSession = Depends(get_db),
    product_id: int,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Get product by ID. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    stmt = select(Product).filter(Product.id == product_id)
    if tenant_id is not None:
        stmt = stmt.filter(Product.tenant_id == tenant_id)
        
    result = await db.execute(stmt)
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    *,
    db: AsyncSession = Depends(get_db),
    product_id: int,
    product_in: ProductUpdate,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Update a product. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    stmt = select(Product).filter(Product.id == product_id)
    if tenant_id is not None:
        stmt = stmt.filter(Product.tenant_id == tenant_id)
        
    result = await db.execute(stmt)
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    update_data = product_in.model_dump(exclude_unset=True)

    # Handle nested pydantic model dumping for thing_model
    if "thing_model" in update_data and update_data["thing_model"] is not None:
        update_data["thing_model"] = product_in.thing_model.model_dump()

    for field, value in update_data.items():
        setattr(product, field, value)

    db.add(product)
    await db.commit()
    await db.refresh(product)
    return product

@router.delete("/{product_id}", response_model=ProductResponse)
async def delete_product(
    *,
    db: AsyncSession = Depends(get_db),
    product_id: int,
    current_user: User = Depends(deps.get_current_tenant_admin),
    request: Request = None,
) -> Any:
    """
    Delete a product. (Admin only)
    """
    tenant_id = getattr(request.state, "tenant_id", None) if request else None
    
    stmt = select(Product).filter(Product.id == product_id)
    if tenant_id is not None:
        stmt = stmt.filter(Product.tenant_id == tenant_id)
        
    result = await db.execute(stmt)
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    await db.delete(product)
    await db.commit()
    return product
