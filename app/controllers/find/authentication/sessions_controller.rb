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
        Sentry.capture_exception(request.env["omniauth.error"])

        render "errors/omniauth"
      end
    end
  end
end
