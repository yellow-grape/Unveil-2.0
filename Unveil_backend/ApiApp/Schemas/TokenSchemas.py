from ninja import Schema


class TokenResponseSchema(Schema):
    access_token: str
    token_type: str
    expires_at: str 
    # Example usage in a view:
def get_token_response(token, expires_at):
    response = TokenResponseSchema(
        access_token=token,
        token_type="Bearer",
        expires_at=expires_at.isoformat()  # Convert datetime to ISO 8601 string
    )
    return response