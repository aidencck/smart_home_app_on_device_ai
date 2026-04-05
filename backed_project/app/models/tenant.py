from sqlalchemy import Column, String, Integer, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class Tenant(Base):
    __tablename__ = "tenant"
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    plan_type = Column(String, default="free")
    max_devices = Column(Integer, default=100)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
