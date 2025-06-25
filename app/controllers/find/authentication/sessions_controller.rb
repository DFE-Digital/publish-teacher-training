module Find
  module Authentication
    class SessionsController < ApplicationController
      def new; end

      def create
        if (candidate = Candidate.find_or_create_by(params.permit(:email_address)))
          start_new_session_for candidate
          redirect_to find_root_path
        else
          redirect_to find_root_path, alert: "Try another email address or password."
        end
      end

      def destroy
        terminate_session
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
