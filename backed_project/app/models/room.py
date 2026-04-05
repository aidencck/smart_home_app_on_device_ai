from sqlalchemy import Column, String, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.db.base_class import Base

class Room(Base):
    __tablename__ = 'room'
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()), index=True)
    name = Column(String, nullable=False)
    home_id = Column(String, ForeignKey("home.id", ondelete="CASCADE"), nullable=False, index=True)
    
    temperature = Column(Float, nullable=True)
    humidity = Column(Float, nullable=True)
    light_level = Column(Float, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    home = relationship("Home", backref="rooms")
    devices = relationship("Device", backref="room")
