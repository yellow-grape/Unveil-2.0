from ninja import NinjaAPI
from .Routers import Auth,Images,Artwork,Profile


# Create the API instance
api = NinjaAPI()

api.add_router("/Auth", Auth.router)
api.add_router("/Profile", Profile.router)
api.add_router("/Images", Images.router)
api.add_router("/Artwork", Artwork.router)

    