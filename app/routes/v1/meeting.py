import logging
from typing import List, Union

from fastapi import APIRouter, Request, File, UploadFile
from fastapi.exceptions import HTTPException
from fastapi.responses import JSONResponse

from models.protocol import MeetingProtocolFormat, MeetingProtocolResponse

router = APIRouter()


@router.get(
    "/",
    name="generate_meeting_protocol",
    summary="Create a protocol of the provided meeting audio.",
)
async def summarize(
    meeting_protocol_format:MeetingProtocolFormat,
    file: UploadFile = File(
        ...,
        description="An audio file in mp3 format containing the recording of the meeting that shall be summarized.",
    ),
) -> MeetingProtocolResponse:
    try:
        return JSONResponse(content={"mosaic_list": ""})
    except HTTPException:
        raise
    except BaseException as exc:
        logging.error("", exc_info=True)
        raise HTTPException(
            status_code=500, detail="An unknown server error occurred"
        ) from exc
