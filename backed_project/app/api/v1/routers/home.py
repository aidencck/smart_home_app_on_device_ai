from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.api.deps import get_db, get_current_user
from app.models.room import Room
from app.models.device import Device, Binding
from app.models.scene import Scene, user_scene
from app.models.home import Home
from app.schemas.home import HomeSummaryResponse, RoomSummary, DeviceSummary, SceneSummary

router = APIRouter()

@router.get("/summary", response_model=HomeSummaryResponse)
async def get_home_summary(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = current_user["id"]
    
    # Query 1: Get user's rooms (belonging to their homes)
    stmt_rooms = (
        select(Room)
        .join(Home, Room.home_id == Home.id)
        .where(Home.user_id == user_id)
    )
    rooms_result = await db.execute(stmt_rooms)
    rooms = rooms_result.scalars().all()
    
    # Query 2: Get user's bound devices
    stmt_devices = (
        select(Device)
        .join(Binding, Binding.device_id == Device.id)
        .where(Binding.user_id == user_id)
    )
    devices_result = await db.execute(stmt_devices)
    devices = devices_result.scalars().all()
    
    # Query 3: Get user's active scenes
    stmt_scenes = (
        select(Scene)
        .join(user_scene, user_scene.c.scene_id == Scene.id)
        .where(user_scene.c.user_id == user_id, Scene.is_active == True)
    )
    scenes_result = await db.execute(stmt_scenes)
    scenes = scenes_result.scalars().all()
    
    return HomeSummaryResponse(
        rooms=[RoomSummary.model_validate(r) for r in rooms],
        devices=[DeviceSummary.model_validate(d) for d in devices],
        active_scenes=[SceneSummary.model_validate(s) for s in scenes]
    )
