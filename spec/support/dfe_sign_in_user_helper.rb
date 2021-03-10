# frozen_string_literal: true

module DfESignInUserHelper
  def user_exists_in_dfe_sign_in(user:)
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      fake_dfe_sign_in_auth_hash(
        email: user.email,
        sign_in_user_id: user.sign_in_user_id,
        first_name: user.first_name,
        last_name: user.last_name,
      ),
    )
  end

private

  def fake_dfe_sign_in_auth_hash(email:, sign_in_user_id:, first_name:, last_name:)
    {
      "provider" => "dfe",
      "uid" => sign_in_user_id,
      "info" => {
        "name" => "#{first_name} #{last_name}",
        "email" => email,
        "nickname" => nil,
        "first_name" => first_name,
        "last_name" => last_name,
        "gender" => nil,
        "image" => nil,
        "phone" => nil,
        "urls" => { "website" => nil },
      },
      "credentials" => {
        "id_token" => "id_token",
        "token" => "DFE_SIGN_IN_TOKEN",
        "refresh_token" => nil,
        "expires_in" => 3600,
        "scope" => "email openid",
      },
      "extra" => {
        "raw_info" => {
          "email" => email,
          "sub" => sign_in_user_id,
        },
      },
    }
  end
end
