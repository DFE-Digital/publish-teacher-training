module Find
  class SessionsController < ApplicationController
    # allow_unauthenticated_access only: %i[new create]
    # rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

    def new; end

    def create
      # if (candidate = Candidate.authenticate_by(params.permit(:email_address)))
      if (candidate = Candidate.find_or_create_by(params.permit(:email_address)))
        start_new_session_for candidate
        redirect_to find_root_path
        # redirect_to after_authentication_url
      else
        # redirect_to new_session_path, alert: "Try another email address or password."
        redirect_to find_root_path, alert: "Try another email address or password."
      end
    end

    def destroy
      terminate_session
      # redirect_to new_session_path
      redirect_to find_root_path
    end
  end
end
