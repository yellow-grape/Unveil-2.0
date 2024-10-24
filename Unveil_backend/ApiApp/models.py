from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
import secrets


class TokenClass(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # Link to the User model
    token = models.CharField(max_length=255, unique=True, default=secrets.token_urlsafe)  # Secure token
    created_at = models.DateTimeField(auto_now_add=True)  # Timestamp when token is created
    expires_at = models.DateTimeField(null=False, blank=False)  # Expiration time of the token

    def is_valid(self):
        """Check if the token is still valid (not expired)."""
        return self.expires_at > timezone.now()

    def __str__(self):
        return f"{self.user.username} - {self.token}"


class ArtWork(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)  # Relationship with the User model
    created_at = models.DateTimeField(auto_now_add=True)  # Automatically sets the date when artwork is created
    artwork_image = models.ImageField(upload_to='artwork/')  # Artwork image file, saved in media/artwork/
    description = models.TextField()  # Field for artwork description
    title = models.CharField(max_length=255)  # Title of the artwork, limit to 255 characters
    likes = models.IntegerField(default=0)  # Count of likes
    dislikes = models.IntegerField(default=0)  # Count of dislikes

    def __str__(self):
        return self.title


class Interaction(models.Model):
    INTERACTION_TYPES = [
        ('like', 'Like'),
        ('dislike', 'Dislike'),
        ('comment', 'Comment'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)  # The user who interacted
    artwork = models.ForeignKey(ArtWork, on_delete=models.CASCADE)  # The artwork being interacted with
    interaction_type = models.CharField(max_length=10, choices=INTERACTION_TYPES)  # Type of interaction
    message = models.TextField(blank=True, null=True)  # Optional message for comments
    created_at = models.DateTimeField(auto_now_add=True)  # When the interaction was made

    def __str__(self):
        return f"{self.user.username} {self.interaction_type} on {self.artwork.title}"


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)  # Link to the User model (one-to-one relationship)
    name = models.CharField(max_length=255, blank=True, null=True)  # Profile name, optional
    profile_pic = models.ImageField(upload_to='profiles/', blank=True, null=True)  # Profile picture, optional
    created_at = models.DateTimeField(auto_now_add=True)  # Automatically sets the date when profile is created

    def __str__(self):
        return f"{self.user.username}'s Profile"
