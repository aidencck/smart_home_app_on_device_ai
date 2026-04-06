from sqlalchemy import Column, String
from app.db.base_class import Base
class RuleLog(Base):
    __tablename__ = 'rule_log'
    id = Column(String, primary_key=True)
