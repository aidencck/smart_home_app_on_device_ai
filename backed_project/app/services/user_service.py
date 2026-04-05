from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User

class UserService:
    async def update(self, db: AsyncSession, *, db_obj: User, obj_in: dict) -> User:
        for field in obj_in:
            if hasattr(db_obj, field):
                setattr(db_obj, field, obj_in[field])
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

user_service = UserService()
