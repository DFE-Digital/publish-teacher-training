module Find
  module Authentication
    class SessionsController < ApplicationController
      def callback
        email_address = omniauth.info.email
        if (candidate = Candidate.find_or_create_by(email_address:))
          start_new_session_for candidate, omniauth
          flash[:success] = t(".sign_in")
          redirect_to(session["return_to_after_authenticating"] || find_root_path, allow_remote_host: false)
        else
          redirect_to find_root_path, flash: { warning: t(".authentication_error") }
        end
      end

      def destroy
        terminate_session
        flash[:success] = t(".sign_out")
        redirect_to find_root_path
      end

      # We render this action when an authentication error occurs
      #
      # request.env["omniauth.error"] # => #<JWT::EncodeError: The given key is a String. It has to be an OpenSSL::PKey::RSA instance>,
      # request.env["omniauth.error.type"] # => :"The given key is a String. It has to be an OpenSSL::PKey::RSA instance",
      # request.env["omniauth.error.strategy"] # => #<OmniAuth::Strategies::GovukOneLogin>
      def failure
        exception = request.env["omniauth.error"]
        strategy = request.env["omniauth.error.strategy"]
        error_type = request.env["omniauth.error.type"]

        if exception
          Sentry.capture_exception(exception, extra: {
            provider: strategy&.name,
            error_type: error_type,
          })
        elsif error_type
          Sentry.capture_message("OmniAuth failure without exception", extra: {
            error_type:,
          })
        elsif params[:message]
          Sentry.capture_message("OmniAuth failure without exception", extra: {
            error_type: params[:message],
            provider: params[:provider],
          })
        end

        render "errors/omniauth"
      end
    end
  end
end
