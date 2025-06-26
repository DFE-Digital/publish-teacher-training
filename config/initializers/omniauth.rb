# frozen_string_literal: true

require_relative "../../app/services/publish/authentication_service"

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

if Settings.one_login.enabled
  # Generate callback URL for any environment
  host = URI(Settings.find_url).host
  port = Rails.env.development? && "3001"
  path = "/auth/one-login/callback"
  one_login_redirect_uri = if Rails.env.local?
                             URI::HTTP.build(host:, port:, path:)
                           else
                             URI::HTTPS.build(host:, port:, path:)
                           end

  # Load private key from environment variable
  begin
    private_key = OpenSSL::PKey::RSA.new(Settings.one_login.private_key.gsub('\n', "\n"))
  rescue StandardError => e
    Rails.logger.error(e)
  end

  options = {
    name: :"one-login",
    client_id: Settings.one_login.identifier,
    idp_base_url: Settings.one_login.idp_base_url,
    # scope: "openid,email", # default
    # vtr: ["Cl.Cm"], # default
    redirect_uri: one_login_redirect_uri&.to_s,
    private_key:,
  }

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :govuk_one_login, options

    # will call `Users::OmniauthController#failure` if there are any errors during the login process
    on_failure do |env|
      Find::Authentication::SessionsController.action(:failure).call(env)
    end
  end
elsif Rails.env.in?(%w[development test])
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider(:find_developer,
             name: "find-developer",
             fields: %i[uid email],
             uid_field: :uid,
             path_prefix: "/auth",
             callback_path: "/auth/find-developer/callback")
    on_failure do |env|
      Find::Authentication::SessionsController.action(:failure).call(env)
    end
  end
end
