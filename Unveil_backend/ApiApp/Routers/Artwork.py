from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
from ApiApp.Routers.Images import generate_image_url
from ApiApp.Schemas.AuthSchemas import ErrorResponse
from ninja import Router
from ApiApp.models import ArtWork
from ApiApp.Schemas.ArtworkSchemas import ArtworkCreateSchema, ArtworkResponse
from ninja.security import HttpBearer
from .Auth import AuthBearer
from django.core.files.storage import default_storage
from django.http import HttpRequest
from ninja.files import UploadedFile
from ninja import File

router = Router()

@router.post("/artwork/", response={201: ArtworkResponse, 400: ErrorResponse}, auth=AuthBearer())
def create_artwork(request, payload: ArtworkCreateSchema):
    artwork = ArtWork.objects.create(
        author=request.auth,  # Use the authenticated user
        artwork_image=payload.artwork_image,  # Ensure this field matches your model field name
        title=payload.title,
        description=payload.description,

    )

    response_data = ArtworkResponse(
        id=artwork.id,
        author=artwork.author.username,
        artwork_image=artwork.artwork_image.url,  # Ensure you're accessing the correct field for the image
        title=artwork.title,
        description=artwork.description,
        created_at=artwork.created_at
    )
    
    return 201, response_data

@router.get("/artwork/", response={200: list[ArtworkResponse]})
def fetch_artworks(request):
    artworks = ArtWork.objects.all()
    return [
        {
            "id": artwork.id,
            "author": artwork.author.username,
            "artwork_image": artwork.artwork_image.url,
            "title": artwork.title,
            "description": artwork.description,
            "created_at": artwork.created_at.isoformat()
        }
        for artwork in artworks
    ]

@router.post("/upload-artwork/")
def upload_image(request: HttpRequest, file: UploadedFile = File(...)):
    file_path = f"artwork/{file.name}"
    file_name = default_storage.save(file_path, file)
    image_url = generate_image_url(request, file_name)
    return {"message": "Image uploaded successfully", "image_url": image_url}

@router.get("/artwork/{artwork_id}/", response={200: ArtworkResponse, 404: ErrorResponse})
def fetch_artwork(request, artwork_id: int):
    artwork = get_object_or_404(ArtWork, id=artwork_id)
    return {
        "id": artwork.id,
        "author": artwork.author.username,
        "artwork_image": artwork.artwork_image.url,
        "title": artwork.title,
        "description": artwork.description,
        "created_at": artwork.created_at.isoformat()
    }

@router.put("/artwork/{artwork_id}/", response={200: ArtworkResponse, 404: ErrorResponse, 400: ErrorResponse}, auth=AuthBearer())
def update_artwork(request, artwork_id: int, payload: ArtworkCreateSchema):
    artwork = get_object_or_404(ArtWork, id=artwork_id)
    
    if artwork.author != request.auth:
        return 403, {"error": "You do not have permission to update this artwork"}

    artwork.artwork_image = payload.artwork_image  # Corrected field name
    artwork.title = payload.title
    artwork.description = payload.description
    artwork.save()

    return {
        "id": artwork.id,
        "author": artwork.author.username,
        "artwork_image": artwork.artwork_image.url,
        "title": artwork.title,
        "description": artwork.description,
        "created_at": artwork.created_at.isoformat()
    }

@router.delete("/artwork/{artwork_id}/", response={204: None, 404: ErrorResponse}, auth=AuthBearer())
def delete_artwork(request, artwork_id: int):
    artwork = get_object_or_404(ArtWork, id=artwork_id)

    if artwork.author != request.auth:
        return 403, {"error": "You do not have permission to delete this artwork"}

    artwork.delete()
    return 204, None
