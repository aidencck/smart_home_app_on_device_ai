from sqlalchemy import Column, String
from app.db.base_class import Base
class Rule(Base):
    __tablename__ = 'rule'
    id = Column(String, primary_key=True)
