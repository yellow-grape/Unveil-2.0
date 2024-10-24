from django.contrib import admin
from .models import TokenClass,ArtWork,Profile,Interaction
# Register your models herfe.
admin.site.register(TokenClass)
admin.site.register(ArtWork)
admin.site.register(Profile)
admin.site.register(Interaction)