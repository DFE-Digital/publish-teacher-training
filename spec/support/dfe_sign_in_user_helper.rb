# frozen_string_literal: true

module DfESignInUserHelper
  def sign_in_system_test(user:)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign-in"
  end

  def user_exists_in_dfe_sign_in(user:)
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      fake_dfe_sign_in_auth_hash(
        email: user.email,
        subject_key: user.authentications.dfe_signin.first&.subject_key,
        first_name: user.first_name,
        last_name: user.last_name,
      ),
    )
  end

  # Helper to login user for request specs
  def login_user(user)
    get "/auth/dfe/callback", headers: { "omniauth.auth" => user_exists_in_dfe_sign_in(user:) }
  end

private

  def fake_dfe_sign_in_auth_hash(email:, subject_key:, first_name:, last_name:)
    {
      "provider" => "dfe",
      "uid" => subject_key,
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
          "sub" => subject_key,
        },
      },
    }
  end
end
