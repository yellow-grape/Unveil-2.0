from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
from ApiApp.Routers.Auth import AuthBearer
from ApiApp.Schemas.AuthSchemas import ErrorResponse
from ApiApp.Schemas.ProfileSchemas import ProfileCreateSchema, ProfileResponseSchema
from ApiApp.models import Profile
from ninja import Router
from django.core.files.base import ContentFile

router = Router()

# Create or update profile
@router.post("/", response=ProfileResponseSchema, auth=AuthBearer())
def create_or_update_profile(request, profile_data: ProfileCreateSchema):
    user = request.user  # Get the authenticated user from the request

    # Check if the profile already exists
    profile, created = Profile.objects.get_or_create(user=user)
    
    # Update profile fields
    profile.name = profile_data.name
    
    # Handle file upload if provided
    if profile_data.profile_pic:
        file_name = f"profile_pic_{user.id}.jpg"  # Use a sensible name for the file
        profile.profile_pic.save(file_name, ContentFile(profile_data.profile_pic))
    
    profile.save()

    # Determine the message based on whether the profile was created or updated
    message = "Profile created successfully." if created else "Profile updated successfully."
    
    return ProfileResponseSchema(
        user_id=profile.user.id,
        name=profile.name,
        profile_pic=profile.profile_pic.url if profile.profile_pic else None,
        created_at=profile.created_at
    )

# Update existing profile
@router.put("/{user_id}/", response=ProfileResponseSchema, auth=AuthBearer())
def update_profile(request, user_id: int, profile_data: ProfileCreateSchema):
    profile = get_object_or_404(Profile, user_id=user_id)

    # Update profile fields excluding profile_pic for special handling
    for attr, value in profile_data.dict(exclude={"profile_pic"}).items():
        setattr(profile, attr, value)

    # Handle file upload if provided
    if profile_data.profile_pic:
        file_name = f"profile_pic_{profile.user.id}.jpg"  # Use the correct user ID
        profile.profile_pic.save(file_name, ContentFile(profile_data.profile_pic))
    
    profile.save()
    return ProfileResponseSchema(
        user_id=profile.user.id,
        name=profile.name,
        profile_pic=profile.profile_pic.url if profile.profile_pic else None,
        created_at=profile.created_at
    )

# Fetch profile
@router.get("/{user_id}/", response=ProfileResponseSchema, auth=AuthBearer())
def fetch_profile(request, user_id: int):
    # Retrieve the profile associated with the given user ID
    profile = get_object_or_404(Profile, user_id=user_id)
    
    return ProfileResponseSchema(
        user_id=profile.user.id,
        name=profile.name,
        profile_pic=profile.profile_pic.url if profile.profile_pic else None,
        created_at=profile.created_at
    )
