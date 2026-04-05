from pydantic import BaseModel, EmailStr
from typing import Optional

class User(BaseModel):
    id: str
    email: EmailStr
    role: str
    tenant_id: Optional[str]
    is_active: bool
    class Config:
        orm_mode = True
