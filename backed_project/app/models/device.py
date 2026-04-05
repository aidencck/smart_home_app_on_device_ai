from sqlalchemy import Column, String, Boolean, ForeignKey, DateTime, Integer, Index, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.db.base_class import Base

class Device(Base):
    __tablename__ = 'device'
    __table_args__ = (Index('ix_device_online_status', 'is_online', 'last_seen'),)
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()), index=True)
    name = Column(String, nullable=False)
    product_id = Column(String, ForeignKey("product.id", ondelete="SET NULL"), nullable=True)
    tenant_id = Column(String, ForeignKey("tenant.id", ondelete="CASCADE"), nullable=True)
    mac_address = Column(String, unique=True, index=True, nullable=True)
    room_id = Column(String, ForeignKey("room.id", ondelete="SET NULL"), nullable=True, index=True)
    firmware_version = Column(String, nullable=True)
    is_online = Column(Boolean, default=False)
    last_seen = Column(DateTime(timezone=True), nullable=True)
    state = Column(String, nullable=True)
    vector_clock = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    bindings = relationship("Binding", back_populates="device", cascade="all, delete-orphan")

class Binding(Base):
    __tablename__ = 'binding'
    __table_args__ = (UniqueConstraint('user_id', 'device_id', name='uq_user_device_binding'),)

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()), index=True)
    user_id = Column(String, ForeignKey("user.id", ondelete="CASCADE"), nullable=False, index=True)
    device_id = Column(String, ForeignKey("device.id", ondelete="CASCADE"), nullable=False, index=True)
    role = Column(String, default="owner")  # owner, admin, user
    bound_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", backref="bindings")
    device = relationship("Device", back_populates="bindings")
