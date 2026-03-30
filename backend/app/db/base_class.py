from sqlalchemy.orm import DeclarativeBase, declared_attr
import re

def camel_to_snake(name: str) -> str:
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()

class Base(DeclarativeBase):
    id: any
    __name__: str
    
    # Generate __tablename__ automatically
    @declared_attr.directive
    def __tablename__(cls) -> str:
        return camel_to_snake(cls.__name__)
