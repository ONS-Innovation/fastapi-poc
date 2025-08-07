from fastapi import APIRouter

router = APIRouter(prefix="/technologies", tags=["technologies"])

@router.get("")
async def get_technologies():
    return {"message": "List of technologies"}
