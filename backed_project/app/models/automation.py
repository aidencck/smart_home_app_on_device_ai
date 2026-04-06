from sqlalchemy import Column, String, Boolean, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class Automation(Base):
    __tablename__ = "automation"
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    is_enabled = Column(Boolean, default=True)
    condition_json = Column(JSON, nullable=False)
    action_json = Column(JSON, nullable=False)
    user_id = Column(String, ForeignKey("user.id"), nullable=False, index=True)

    user = relationship("User")

class AIRecommendation(Base):
    __tablename__ = "ai_recommendation"
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("user.id"), nullable=False, index=True)
    description = Column(String, nullable=False)
    status = Column(String, default="pending") # pending, accepted, rejected
    action_payload = Column(JSON, nullable=False)

    user = relationship("User")
