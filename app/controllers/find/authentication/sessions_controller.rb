module Find
  module Authentication
    class SessionsController < ApplicationController
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
    end
  end
end
