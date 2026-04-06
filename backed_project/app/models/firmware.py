from sqlalchemy import Column, String
from app.db.base_class import Base
class Firmware(Base):
    __tablename__ = 'firmware'
    id = Column(String, primary_key=True)
