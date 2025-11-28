# frozen_string_literal: true

module Authentications
  class DfESignInOmniAuth
    CALLBACK_PATH = "/auth/dfe/callback"
    SCOPE = %i[email profile].freeze

    # Returns the provider symbol for DfE Sign-In
    def provider
      :openid_connect
    end

    # Returns the options hash for DfE Sign-In OmniAuth configuration
    def options
      {
        name: :dfe,
        discovery: true,
        response_type: :code,
        scope: SCOPE,
        path_prefix: "/auth",
        callback_path: CALLBACK_PATH,
        client_options:,
        issuer: issuer,
      }
    end

  private

    # Returns the client options hash for OmniAuth configuration
    def client_options
      {
        identifier: Settings.dfe_signin.identifier,
        port: issuer_uri.port,
        scheme: issuer_uri.scheme,
        host: issuer_uri.host,
        secret: Settings.dfe_signin.secret,
        redirect_uri: redirect_uri,
      }
    end

    # Returns the redirect URI for OmniAuth configuration
    def redirect_uri
      @redirect_uri ||= URI.join(Settings.base_url, CALLBACK_PATH)&.to_s
    end

    # Returns the issuer URI for OmniAuth configuration
    def issuer_uri
      @issuer_uri ||= URI.parse(Settings.dfe_signin.issuer)
    end

    # Returns the issuer string for OmniAuth configuration
    def issuer
      "#{issuer_uri}:#{issuer_uri.port}" if issuer_uri.present?
    end
  end
end
