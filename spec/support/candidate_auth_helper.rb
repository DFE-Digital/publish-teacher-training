module CandidateAuthHelper
module_function

  def mock_auth(email_address: "candidateemail@example.com")
    OmniAuth.config.mock_auth[:"find-developer"] = OmniAuth::AuthHash.new(
      {
        "provider" => "find-developer",
        "uid" => "sign_in_user_id",
        "info" => {
          "name" => "candidate test",
          "email" => email_address,
        },
        "credentials" => {
          "id_token" => "id_token",
          "token" => "CANDIDATE_SIGN_IN_TOKEN",
          "expires_in" => 3600,
          "scope" => "email openid",
        },
        "extra" => {
          "raw_info" => {
            "email" => email_address,
            "sub" => "sign_in_user_id",
          },
        },
      },
    )
  end

  # This auth will fail! and exception in OmniAuth and trigger the failure flow
  def mock_error_auth
    OmniAuth.config.mock_auth[:"find-developer"] = :fail
  end
end
