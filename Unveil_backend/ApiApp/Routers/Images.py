import os
from ninja import Router, File
from ninja.files import UploadedFile
from django.conf import settings
from django.core.files.storage import default_storage
from django.shortcuts import get_object_or_404
from django.http import Http404, HttpRequest
from urllib.parse import urljoin

from ApiApp.models import ArtWork

router = Router()
def generate_image_url(request, file_name):
    
    # Ensure file_name is safe and doesn't contain any unwanted characters
    return f"{request.scheme}://{request.get_host()}/{file_name}"
@router.get("/fetch-image/{artwork_id}")
def fetch_image(request: HttpRequest, artwork_id: int):
    artwork_ = get_object_or_404(ArtWork, id=artwork_id)
    
    # Access the image file name
    file_name = artwork_.artwork_image.name
    
    # Construct the full file path
    file_path = os.path.join(settings.MEDIA_ROOT, file_name)
    
    # Check if the file exists in storage
    if not default_storage.exists(file_path):
        raise Http404("Image not found")
    
    # Generate a URL for the image
    image_url = generate_image_url(request, file_name)
    
    return {"image_url": image_url}