from django.shortcuts import get_object_or_404
from django.core.files.storage import default_storage
from ninja import Form, Router, File
from ninja.files import UploadedFile
from ApiApp.models import ArtWork
from ApiApp.Routers.Images import generate_image_url
from ApiApp.Schemas.AuthSchemas import ErrorResponse
from ApiApp.Schemas.ArtworkSchemas import ArtworkCreateSchema, ArtworkResponse
from .Auth import AuthBearer

router = Router()

@router.post("/artwork/", response={201: ArtworkResponse, 400: ErrorResponse}, auth=AuthBearer())
def create_artwork(request, payload: Form[ArtworkCreateSchema], file: File[UploadedFile]):
    artwork_image = file

    if artwork_image:
        # Save the uploaded file and generate the file name
        file_name = default_storage.save(f"media/artwork/{artwork_image.name}", artwork_image)
        # Generate the correct image URL
        artwork_image_url = generate_image_url(request, file_name)

        # Create the artwork entry
        artwork = ArtWork.objects.create(
            author=request.auth,
            artwork_image=file_name,  # Store the file name
            title=payload.title,
            description=payload.description,
        )

        # Prepare the response data
        response_data = ArtworkResponse(
            id=artwork.id,
            author=artwork.author.username,
            artwork_image=artwork_image_url,  # Use the generated URL
            title=artwork.title,
            description=artwork.description,
            created_at=artwork.created_at.isoformat()
        )
        return 201, response_data

    return 400, {"error": "No artwork image provided"}

@router.put("/artwork/{artwork_id}/", response={200: ArtworkResponse, 404: ErrorResponse, 400: ErrorResponse}, auth=AuthBearer())
def update_artwork(request, artwork_id: int, payload: ArtworkCreateSchema):
    artwork = get_object_or_404(ArtWork, id=artwork_id)

    if artwork.author != request.auth:
        return 403, {"error": "You do not have permission to update this artwork"}

    if hasattr(payload, 'artwork_image') and payload.artwork_image:
        artwork_image = payload.artwork_image
        # Save the new image
        file_name = default_storage.save(f"artwork/{artwork_image.name}", artwork_image)
        artwork.artwork_image = file_name  # Store the file name
        artwork.artwork_image_url = generate_image_url(request, file_name)  # Update URL

    artwork.title = payload.title
    artwork.description = payload.description
    artwork.save()

    return {
        "id": artwork.id,
        "author": artwork.author.username,
        "artwork_image": artwork.artwork_image_url,  # Use the generated URL
        "title": artwork.title,
        "description": artwork.description,
        "created_at": artwork.created_at.isoformat()
    }

@router.get("/artwork/{artwork_id}/", response={200: ArtworkResponse, 404: ErrorResponse})
def fetch_artwork(request, artwork_id: int):
    artwork = get_object_or_404(ArtWork, id=artwork_id)
    return {
        "id": artwork.id,
        "author": artwork.author.username,
        "artwork_image": generate_image_url(request, artwork.artwork_image),  # Generate URL
        "title": artwork.title,
        "description": artwork.description,
        "created_at": artwork.created_at.isoformat()
    }
