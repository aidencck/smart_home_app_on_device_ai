from sqlalchemy import Column, String
from app.db.base_class import Base
class OTAJob(Base):
    __tablename__ = 'ota_job'
    id = Column(String, primary_key=True)
class OTAExecution(Base):
    __tablename__ = 'ota_execution'
    id = Column(String, primary_key=True)
