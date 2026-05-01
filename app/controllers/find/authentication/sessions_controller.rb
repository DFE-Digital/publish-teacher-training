module Find
  module Authentication
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: %i[backchannel_logout]

      KNOWN_ONE_LOGIN_ERROR_TYPES = %w[
        openid_discovery
        callback_state_mismatch
        callback_access_denied
        callback_invalid_request
        callback_service_unavailable
        callback_login_required
        id_token_request
        id_token_nonce_mismatch
        id_token_iss_mismatch
        id_token_aud_mismatch
        id_token_iat_mismatch
        id_token_exp_mismatch
        id_token_vot_mismatch
        userinfo_request
        logout_token_exp_mismatch
        logout_token_aud_mismatch
        logout_token_iat_mismatch
        logout_token_iss_mismatch
        logout_token_sub_mismatch
        logout_token_events_claim_mismatch
        invalid_credentials
        timeout
        csrf_detected
        invalid_response
        connection_failed
        invalid_authenticity_token
      ].freeze

      SAMPLED_ONE_LOGIN_ERROR_TYPES = %w[invalid_authenticity_token other].freeze

      def callback
        candidate = Find::CandidateAuthenticator.new(oauth: omniauth).call

        if start_new_session_for candidate, omniauth
          if session["save_course_id_after_authenticating"].present?
            redirect_to after_auth_find_candidate_saved_courses_path
          else
            flash[:success] = t(".sign_in")
            redirect_to(session.delete("return_to_after_authenticating") || find_root_path, allow_remote_host: false)
          end
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
        error_type = normalized_one_login_error_type
        sampled = SAMPLED_ONE_LOGIN_ERROR_TYPES.include?(error_type)

        if !sampled || ErrorReporting::RateLimiter.report?(key: "one_login:#{error_type}", threshold: 10)
          Sentry.capture_message("One Login failure", tags: {
            error_type:,
            sample_rate: sampled ? 10 : 1,
          }, extra: {
            session_id: request.session&.id&.public_id,
          })
        end

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

      def normalized_one_login_error_type
        candidate = params[:message].to_s.demodulize.underscore.sub(/_error\z/, "")
        KNOWN_ONE_LOGIN_ERROR_TYPES.include?(candidate) ? candidate : "other"
      end

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
