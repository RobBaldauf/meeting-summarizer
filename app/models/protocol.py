from enum import Enum
from pydantic import BaseModel, Extra

class ProtocolType(str, Enum):
    short = "short"
    detailled = "detailled"

class MeetingProtocolFormat(BaseModel):
    """This is the serializer used for the request format attribute."""

    type: ProtocolType

class MeetingProtocolResponse(BaseModel):
    """This the serializer used for the response."""

    protocoll_text: str