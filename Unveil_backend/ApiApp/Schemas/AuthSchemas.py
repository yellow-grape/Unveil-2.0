# myapp/views.py

from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from ninja import NinjaAPI, Schema


api = NinjaAPI()

class UserCreateSchema(Schema):
    username: str
    password: str 
    email: str

class UserLoginSchema(Schema):
    email: str
    password: str 

class UserCreateResponse(Schema):
    message: str

class LoginResponse(Schema):
    message: str
    token:str

class ErrorResponse(Schema):
    error: str

