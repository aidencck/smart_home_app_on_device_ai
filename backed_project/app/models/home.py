from sqlalchemy import Column, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base_class import Base

class Home(Base):
    __tablename__ = "home"
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    user_id = Column(String, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User")
