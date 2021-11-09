# frozen_string_literal: true

require_relative "../../app/services/authentication_service"

if AuthenticationService.persona?

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :developer,
             fields: %i[uid email first_name last_name],
             uid_field: :uid
  end
else

  OmniAuth.config.logger = Rails.logger

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
    client_options: client_options,
  }

module OmniAuth
  module Strategies
    class OpenIDConnect
      def authorize_uri
        client.redirect_uri = redirect_uri
        opts = {
          response_type: options.response_type,
          scope: options.scope,
          state: new_state,
          nonce: (new_nonce if options.send_nonce),
          hd: options.hd,
          prompt: :consent,
        }
        client.authorization_uri(opts.reject { |_, v| v.nil? })
      end

      def callback_phase
        error = request.params["error_reason"] || request.params["error"]
        if error == "sessionexpired"
          redirect("/sign-in")
        elsif error
          raise CallbackError.new(request.params["error"], request.params["error_description"] || request.params["error_reason"], request.params["error_uri"])
        elsif request.params["state"].to_s.empty? || request.params["state"] != stored_state
          # Monkey patch: Ensure a basic 401 rack response with no body or header isn't served
          # return Rack::Response.new(['401 Unauthorized'], 401).finish
          redirect("/auth/failure")
        elsif !request.params["code"]
          fail!(:missing_code, OmniAuth::OpenIDConnect::MissingCodeError.new(request.params["error"]))
        else
          options.issuer = issuer if options.issuer.blank?
          discover! if options.discovery
          client.redirect_uri = redirect_uri
          client.authorization_code = authorization_code
          access_token
          super
        end
      rescue CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      rescue Rack::OAuth2::Client::Error => e
        Rails.logger.error "Auth failure, is Settings.dfe_signin.secret correct? #{e}"
        raise
      end
    end
  end
end
  Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, options

end
