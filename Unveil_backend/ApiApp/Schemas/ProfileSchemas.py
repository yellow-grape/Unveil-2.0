# ApiApp/Schemas/ProfileSchemas.py

from ninja import Schema, File
from datetime import datetime
from pydantic import HttpUrl, Field
class ProfileCreateSchema(Schema):
    """Schema for creating a profile."""
    name: str = Field(..., max_length=255, description="The name of the user.")
    profile_pic: bytes = Field(None, description="Optional binary data of the profile picture.")

class ProfileResponseSchema(Schema):
    """Schema for responding with profile information."""
    user_id: int = Field(..., description="The unique ID of the user.")
    name: str = Field(..., description="The name of the user.")
    profile_pic: str = Field(None, description="URL of the profile picture.")
    created_at: datetime = Field(..., description="The date and time when the profile was created.")