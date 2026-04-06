from sqlalchemy import Column, String
from app.db.base_class import Base

class Product(Base):
    __tablename__ = 'product'
    id = Column(String, primary_key=True)
