module Authentications
  class CandidateOmniAuth
    ONE_LOGIN_PATH = "/auth/one-login".freeze
    DEVELOPER_PATH = "/auth/find-developer".freeze

    attr_reader :provider

    # The path candidates sign in through. Outside production One Login is
    # disabled and the developer strategy stands in for it.
    def self.sign_in_path
      Settings.one_login.enabled ? ONE_LOGIN_PATH : DEVELOPER_PATH
    end

    def initialize
      @provider = set_provider
    end

    def options
      if one_login?
        {
          name: :"one-login",
          client_id: Settings.one_login.identifier,
          idp_base_url: Settings.one_login.idp_base_url,
          scope: "openid email",
          # vtr: ["Cl.Cm"], # default
          redirect_uri:,
          private_key:,
        }
      elsif !Rails.env.production?
        {
          name: "find-developer",
          fields: %i[uid email],
          uid_field: :uid,
          path_prefix: "/auth",
          callback_path: "/auth/find-developer/callback",
        }
      end
    end

    def config
      yield self if block_given? && @provider.present?
    end

  private

    def one_login?
      Settings.one_login.enabled
    end

    def set_provider
      if Settings.one_login.enabled
        :govuk_one_login
      elsif !Rails.env.production?
        :find_developer
      end
    end

    def redirect_uri
      # Generate callback URL for any environment
      host = URI(Settings.find_url).host
      port = Rails.env.development? && "3001"
      path = "/auth/one-login/callback"
      protocol = Rails.env.local? ? URI::HTTP : URI::HTTPS
      protocol.build(host:, port:, path:).to_s
    end

    def private_key
      # Load private key from environment variable
      OpenSSL::PKey::RSA.new(Settings.one_login.private_key.gsub('\n', "\n"))
    rescue StandardError => e
      Sentry.capture_exception(e)
      Rails.logger.error(e)
      nil
    end
  end
end
