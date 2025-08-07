from fastapi import APIRouter
from .endpoints import technologies, projects

router = APIRouter()

@router.get("")
async def root():
    return {
        "message": "Welcome to the API v0",
    }

# Include the endpoints in the router
router.include_router(technologies.router)
router.include_router(projects.router)