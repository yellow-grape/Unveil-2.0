from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from django.utils.crypto import get_random_string
from django.utils import timezone
from datetime import timedelta
from ApiApp.Schemas.AuthSchemas import ErrorResponse, LoginResponse, UserCreateResponse, UserCreateSchema, UserLoginSchema,UserdataResponce
from ninja import Router
from ApiApp.models import TokenClass
from ninja.security import HttpBearer

router = Router()

# Token expiration time (e.g., 1 day)
TOKEN_EXPIRATION_HOURS = 24

# User registration endpoint
@router.post("/register/", response={201: UserCreateResponse, 400: ErrorResponse})
def register(request, payload: UserCreateSchema):
    # Check if the email already exists
    if User.objects.filter(email=payload.email).exists():
        return 400, {"error": "Email already registered"}

    # Create the user
    user = User.objects.create(
        username=payload.email,  # Optionally store the email as username
        email=payload.email,
        password=make_password(payload.password),  # Hash the password
    )

    # Create a token for the user with expiration
    token = get_random_string(32)  # Generate a random token
    expires_at = timezone.now() + timedelta(hours=TOKEN_EXPIRATION_HOURS)  # Set expiration time
    TokenClass.objects.create(user=user, token=token, expires_at=expires_at)  # Store the token with expiration

    return 201, {"message": f"User created successfully: {user.username}", "token": token}


# User login endpoint
@router.post("/login/", response={200: LoginResponse, 401: ErrorResponse})
def login(request, payload: UserLoginSchema):
    # Authenticate user using email instead of username
    user = authenticate(request, username=payload.email, password=payload.password)
    
    if user is not None:
        # Fetch the token from the TokenClass associated with the user
        token_instance = TokenClass.objects.filter(user=user).first()
        
        if token_instance:
            # Check if the token has expired
            if token_instance.expires_at > timezone.now():
                token = token_instance.token  # Token is valid
            else:
                # Token has expired, generate a new token
                token = get_random_string(32)
                token_instance.token = token
                token_instance.expires_at = timezone.now() + timedelta(hours=TOKEN_EXPIRATION_HOURS)
                token_instance.save()  # Save the updated token and expiration time
        else:
            return 401, {"error": "No token found for the user"}

        return 200, {
            "message": f"Hello, {user.username}! You are logged in.",
            "token": token
        }
    else:
        return 401, {"error": "Invalid email or password"}


# AuthBearer for token authentication
class AuthBearer(HttpBearer):
    def authenticate(self, request, token):
        # Check if the token exists in the database and has not expired
        token_instance = TokenClass.objects.filter(token=token).first()

        if token_instance and token_instance.expires_at > timezone.now():
            return token_instance.user  # Return the user if the token is valid and not expired
        return None  # Return None if the token is invalid or expired


# Get authenticated user's profile
@router.get("/user/", response={200: UserdataResponce, 401: ErrorResponse}, auth=AuthBearer())
def get_user(request):
    user = request.auth  # This comes from the AuthBearer
    return UserdataResponce(id=user.id, username=user.username, email=user.email)  # Use response schema

# Protected route example
@router.get("/protected", auth=AuthBearer())
def protected_route(request):
    return {"message": f"Hello, {request.auth.username}. You have access to this protected route."}
