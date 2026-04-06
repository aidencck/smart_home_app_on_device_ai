import asyncio
from app.db.session import engine
from app.db.base_class import Base

# Import all models to register them
from app.models import Device, Binding, User, Room, Scene, Automation, AIRecommendation
from app.models.home import Home
from app.models.product import Product
from app.models.firmware import Firmware

async def init_models():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
        print("Database tables created successfully!")

if __name__ == "__main__":
    asyncio.run(init_models())
