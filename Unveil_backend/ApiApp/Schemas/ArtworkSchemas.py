from typing import Optional
from ninja import Schema
from pydantic import Field
from datetime import datetime

class ArtworkCreateSchema(Schema):
    ArtWork: str = Field(..., description="Path to the artwork image")
    title: str = Field(..., description="Title of the artwork")
    description: Optional[str] = Field(None, description="Description of the artwork")

class ArtworkResponse(Schema):
    id: int
    author: str
    ArtWork: str
    title: str
    description: Optional[str]  # Make description optional in response
    created_at: datetime  # Use datetime type for created_at
    
