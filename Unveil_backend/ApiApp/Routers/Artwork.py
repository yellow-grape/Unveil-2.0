from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
from ApiApp.Schemas.AuthSchemas import ErrorResponse
from ninja import Router
from ApiApp.models import ArtWork  # Adjust import based on your app structure
from ApiApp.Schemas.ArtworkSchemas import ArtworkCreateSchema, ArtworkResponse  # Adjust based on your app structure
from ninja.security import HttpBearer
from .Auth import AuthBearer

router = Router()

@router.post("/artwork/", response={201: ArtworkResponse, 400: ErrorResponse}, auth=AuthBearer())
def create_artwork(request, payload: ArtworkCreateSchema):
    # Create the artwork
    artwork = ArtWork.objects.create(
        author=request.auth,  # Use the authenticated user
        artwork_image=payload.ArtWork,  # Make sure this matches the model field name
        title=payload.title,
        description=payload.description
    )
    
    # Construct the response data
    response_data = ArtworkResponse(
        id=artwork.id,
        author=artwork.author.username,  # Assuming author is a User object
        ArtWork=artwork.artwork_image.url,  # Ensure you're accessing the correct field
        title=artwork.title,
        description=artwork.description,  # This can be None if not provided
        created_at=artwork.created_at  # Django will automatically populate this
    )

    return 201, response_data
@router.get("/artwork/", response={200: list[ArtworkResponse]})
def fetch_artworks(request):
    artworks = ArtWork.objects.all()
    return [{
        "id": artwork.id,
        "author": artwork.author.username,
        "ArtWork": artwork.artwork_image.url,
        "title": artwork.title,
        "description": artwork.description,
        "created_at": artwork.created_at.isoformat()
    } for artwork in artworks]

# Fetch a single artwork by ID (public)
@router.get("/artwork/{artwork_id}/", response={200: ArtworkResponse, 404: ErrorResponse})
def fetch_artwork(request, artwork_id: int):
    artwork = get_object_or_404(ArtWork, id=artwork_id)
    return {
        "id": artwork.id,
        "author": artwork.author.username,
        "ArtWork": artwork.artwork_image.url,
        "title": artwork.title,
        "description": artwork.description,
        "created_at": artwork.created_at.isoformat()
    }

# Update an artwork (protected)
@router.put("/artwork/{artwork_id}/", response={200: ArtworkResponse, 404: ErrorResponse, 400: ErrorResponse}, auth=AuthBearer())
def update_artwork(request, artwork_id: int, payload: ArtworkCreateSchema):
    artwork = get_object_or_404(ArtWork, id=artwork_id)
    
    # Check if the user is the author of the artwork
    if artwork.author != request.auth:
        return 403, {"error": "You do not have permission to update this artwork"}

    # Update fields
    artwork.ArtWork = payload.artwork_image
    artwork.title = payload.title
    artwork.description = payload.description
    
    artwork.save()

    return {
        "id": artwork.id,
        "author": artwork.author.username,
        "ArtWork": artwork.artwork_image.url,
        "title": artwork.title,
        "description": artwork.description,
        "created_at": artwork.created_at.isoformat()
    }

# Delete an artwork (protected)
@router.delete("/artwork/{artwork_id}/", response={204: None, 404: ErrorResponse}, auth=AuthBearer())
def delete_artwork(request, artwork_id: int):
    artwork = get_object_or_404(ArtWork, id=artwork_id)

    # Check if the user is the author of the artwork
    if artwork.author != request.auth:
        return 403, {"error": "You do not have permission to delete this artwork"}

    artwork.delete()
    return 204, None
