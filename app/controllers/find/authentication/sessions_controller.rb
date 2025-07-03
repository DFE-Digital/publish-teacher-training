module Find
  module Authentication
    class SessionsController < ApplicationController
      def callback
        email_address = omniauth.info.email
        authentication = ::Authentication.find_by(subject_key: omniauth.uid)

        if authentication.present?
          candidate = authentication.authenticable
          unless candidate.email_address.casecmp?(email_address)
            candidate.update(email_address:)
          end
        else
          Candidate.transaction do
            candidate = Candidate.create(email_address:)

            candidate.authentications.build(provider: provider_map(omniauth.provider), subject_key: omniauth.uid)
            candidate.save!
          end
        end

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

        if Settings.one_login.enabled
          redirect_to(logout_request(Current.session.id_token).redirect_uri, allow_other_host: true)
        else
          redirect_to(find_root_path)
        end
      end

      def failure
        Sentry.capture_message("One Login failure", extra: {
          error_type: params[:message],
          provider: params[:provider],
        })

        render "errors/omniauth"
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
