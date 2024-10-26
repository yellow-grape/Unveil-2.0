from typing import Optional
from ninja import Schema
from pydantic import Field
from datetime import datetime

class ArtworkCreateSchema(Schema):
    title: str = Field(..., description="Title of the artwork")
    description: Optional[str] = Field(None, description="Description of the artwork")
    

    

class ArtworkResponse(Schema):
    id: int
    author: str
    artwork_image: str  # Change ArtWork to artwork_image
    title: str
    description: Optional[str]
    created_at: datetime  # Use datetime type for created_at
    artwork_image: str  # Change ArtWork to artwork_image

