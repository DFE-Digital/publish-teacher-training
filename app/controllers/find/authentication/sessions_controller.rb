module Find
  module Authentication
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: %i[backchannel_logout]

      def callback
        candidate = Find::CandidateAuthenticator.new(oauth: omniauth).call

        if start_new_session_for candidate, omniauth
          flash[:success] = t(".sign_in")
          redirect_to(session["return_to_after_authenticating"] || find_root_path, allow_remote_host: false)
        else
          redirect_to find_root_path, flash: { warning: t(".authentication_error") }
        end
      end

      def destroy
        terminate_session
        flash[:success] = t(".sign_out")

        # Double clicking Sign out causes exception when Current.session has already been destroyed
        if Settings.one_login.enabled && Current.session
          redirect_to(logout_request(Current.session.id_token).redirect_uri, allow_other_host: true)
        else
          redirect_to(find_root_path)
        end
      end

      def failure
        Sentry.capture_message("One Login failure", extra: {
          error_type: params[:message],
          strategy: params[:strategy],
        })

        render "errors/omniauth"
      end

      def backchannel_logout
        response_status = BackchannelLogout.new(
          params[:logout_token],
          params[:provider],
        ).call

        head response_status
      end

      def backchannel_logout_utility
        OmniAuth::GovukOneLogin::BackchannelLogoutUtility.new(client_id: Settings.one_login.identifier, idp_base_url: Settings.one_login.idp_base_url)
      end

    private

      def logout_request(token)
        logout_utility.build_request(
          id_token_hint: token,
          post_logout_redirect_uri: Settings.one_login.post_logout_url,
        )
      end

      def logout_utility
        OmniAuth::GovukOneLogin::LogoutUtility.new(end_session_endpoint: Settings.one_login.logout_url)
      end
    end
  end
end
