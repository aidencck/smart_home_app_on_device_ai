import asyncio
from app.db.session import async_sessionmaker, engine
from app.api.v1.routers.home import get_home_summary

async def test():
    async with async_sessionmaker(engine)() as db:
        user = {"id": "simulated_user_id", "tenant_id": "simulated_tenant_id", "role": "superuser"}
        try:
            res = await get_home_summary(current_user=user, db=db)
            print(res)
        except Exception as e:
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test())
