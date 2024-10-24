from ninja import Router, File
from ninja.files import UploadedFile
from django.conf import settings
from django.core.files.storage import default_storage
from django.http import Http404
import os

router = Router()

# Function to generate full URL for an image
def generate_image_url(request, image_path: str) -> str:
    """Generate the full URL for an image."""
    return request.build_absolute_uri(f"{settings.MEDIA_URL}{image_path}")

# Route to upload an image
@router.post("/upload-image/")
def upload_image(request, file: UploadedFile = File(...)):
    """Upload an image and return its URL."""
    # Define the path where the image will be saved
    file_path = f"artwork/{file.name}"
    
    # Save the uploaded file
    file_name = default_storage.save(file_path, file)

    # Generate the full URL for the uploaded image
    image_url = generate_image_url(request, file_name)

    return {"message": "Image uploaded successfully", "image_url": image_url}

# Route to fetch the image URL by filename
@router.get("/fetch-image/{file_name}")
def fetch_image(request, file_name: str):
    """Fetch the full URL of an image by its filename."""
    file_path = f"artwork/{file_name}"

    # Check if the file exists
    if not default_storage.exists(file_path):
        raise Http404("Image not found")

    # Generate the full URL
    image_url = generate_image_url(request, file_path)

    return {"image_url": image_url}
