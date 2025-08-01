# frozen_string_literal: true

require_relative "../../app/services/publish/authentication_service"
require_relative "../../app/lib/authentications/candidate_omni_auth"

OmniAuth.config.logger = Rails.logger

if Publish::AuthenticationService.persona?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :developer,
             fields: %i[uid email first_name last_name],
             uid_field: :uid
  end
else
  dfe_sign_in_issuer_uri = URI.parse(Settings.dfe_signin.issuer)
  dfe_sign_in_redirect_uri = URI.join(Settings.base_url, "/auth/dfe/callback")

  client_options = {
    identifier: Settings.dfe_signin.identifier,

    port: dfe_sign_in_issuer_uri.port,
    scheme: dfe_sign_in_issuer_uri.scheme,
    host: dfe_sign_in_issuer_uri.host,

    secret: Settings.dfe_signin.secret,
    redirect_uri: dfe_sign_in_redirect_uri&.to_s,
  }

  options = {
    name: :dfe,
    discovery: true,
    response_type: :code,
    scope: %i[email profile],
    path_prefix: "/auth",
    callback_path: "/auth/dfe/callback",
    client_options:,
    issuer: ("#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}" if dfe_sign_in_issuer_uri.present?),
  }

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :openid_connect, options
  end
end

# Find / Candidate inteface authentication
Authentications::CandidateOmniAuth.new.config do |config|
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider config.provider, config.options
  end
end
