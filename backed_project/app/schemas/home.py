from pydantic import BaseModel
from typing import List, Optional

class DeviceSummary(BaseModel):
    id: str
    name: str
    is_online: bool
    room_id: Optional[str] = None
    
    class Config:
        from_attributes = True

class RoomSummary(BaseModel):
    id: str
    name: str
    temperature: Optional[float] = None
    humidity: Optional[float] = None
    light_level: Optional[float] = None
    
    class Config:
        from_attributes = True

class SceneSummary(BaseModel):
    id: str
    name: str
    is_active: bool
    
    class Config:
        from_attributes = True

class HomeSummaryResponse(BaseModel):
    rooms: List[RoomSummary]
    devices: List[DeviceSummary]
    active_scenes: List[SceneSummary]
