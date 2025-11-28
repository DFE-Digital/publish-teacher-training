# frozen_string_literal: true

require_relative "../../app/services/publish/authentication_service"
require_relative "../../app/lib/authentications/candidate_omni_auth"
require_relative "../../app/lib/authentications/dfe_sign_in_omni_auth"

OmniAuth.config.logger = Rails.logger

if Publish::AuthenticationService.persona?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :developer,
             fields: %i[uid email first_name last_name],
             uid_field: :uid
  end
else
  dfe_sign_in_omni_auth = Authentications::DfESignInOmniAuth.new

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider dfe_sign_in_omni_auth.provider, dfe_sign_in_omni_auth.options
  end
end

# Find / Candidate inteface authentication
Authentications::CandidateOmniAuth.new.config do |config|
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider config.provider, config.options
  end
end
