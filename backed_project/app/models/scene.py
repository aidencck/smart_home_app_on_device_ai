from sqlalchemy import Column, String, Boolean, ForeignKey, DateTime, Table
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.db.base_class import Base

user_scene = Table(
    'user_scene',
    Base.metadata,
    Column('user_id', String, ForeignKey('user.id', ondelete="CASCADE"), primary_key=True),
    Column('scene_id', String, ForeignKey('scene.id', ondelete="CASCADE"), primary_key=True)
)

class Scene(Base):
    __tablename__ = 'scene'
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()), index=True)
    name = Column(String, nullable=False)
    is_active = Column(Boolean, default=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Many-to-Many relationship with User
    users = relationship("User", secondary=user_scene, backref="scenes")
