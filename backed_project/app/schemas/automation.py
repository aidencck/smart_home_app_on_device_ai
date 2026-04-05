from pydantic import BaseModel, Field
from typing import Dict, Any, Optional

class AutomationBase(BaseModel):
    name: str
    is_enabled: bool = True
    condition_json: Dict[str, Any]
    action_json: Dict[str, Any]

class AutomationCreate(AutomationBase):
    pass

class AutomationUpdate(BaseModel):
    name: Optional[str] = None
    is_enabled: Optional[bool] = None
    condition_json: Optional[Dict[str, Any]] = None
    action_json: Optional[Dict[str, Any]] = None

class Automation(AutomationBase):
    id: str
    user_id: str

    class Config:
        orm_mode = True

class AutomationTriggerRequest(BaseModel):
    event_type: str = Field(..., description="触发的事件类型，如 DEEP_SLEEP")
    payload: Dict[str, Any] = Field(default_factory=dict, description="事件携带的额外数据")

class AutomationTriggerResponse(BaseModel):
    message: str
    matched_rules: int
    actions_to_execute: list[Dict[str, Any]]

class AIRecommendationBase(BaseModel):
    description: str
    status: str = "pending"
    action_payload: Dict[str, Any]

class AIRecommendationCreate(AIRecommendationBase):
    user_id: str

class AIRecommendation(AIRecommendationBase):
    id: str
    user_id: str

    class Config:
        orm_mode = True
