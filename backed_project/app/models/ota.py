from app.db.base_class import Base
class OTAJob(Base):
    __tablename__ = 'ota_job'
    id = None
class OTAExecution(Base):
    __tablename__ = 'ota_execution'
    id = None
