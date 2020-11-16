module TokenHelper
  def encode_to_bearer_token(payload)
    token = encode_to_token(payload)

    "Bearer #{token}"
  end

  def encode_to_credentials(payload)
    token = encode_to_token(payload)

    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

private

  def encode_to_token(payload)
    build_jwt(:apiv2, payload: payload)
  end
end
