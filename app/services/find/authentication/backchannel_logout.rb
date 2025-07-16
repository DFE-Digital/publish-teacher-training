module Find
  module Authentication
    class BackchannelLogout
      attr_reader :logout_token, :provider

      def initialize(logout_token, provider)
        @logout_token = logout_token
        @provider = provider
      end

      # @return [Symbol] represents the response code for One Login Backchannel request
      def call
        return :bad_request if logout_token.blank? || uid.blank?

        authentication = ::Authentication.find_by!(subject_key: uid, provider: ::Authentication.provider_map(provider))

        authentication.authenticable.sessions.destroy_all

        :ok
      end

      def uid
        @uid ||= OmniAuth::GovukOneLogin::BackchannelLogoutUtility.new(
          client_id: Settings.one_login.identifier,
          idp_base_url: Settings.one_login.idp_base_url,
        ).get_sub(logout_token:)
      end
    end
  end
end
