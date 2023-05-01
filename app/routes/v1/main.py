from fastapi import APIRouter
from routes.v1.meeting import router as protocol_router

router = APIRouter()
router.include_router(protocol_router, prefix="/protocol", tags=["protocol"])


@router.get("/status")
async def index():
    return {"message": "Meeting protocol service is running!"}
