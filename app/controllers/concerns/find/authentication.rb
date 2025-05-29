module Find
  module Authentication
    extend ActiveSupport::Concern

    included do
      # before_action :require_authentication
      before_action :load_session
      helper_method :authenticated?
      helper_method :candidate_session
    end

  protected

    def candidate_session
      CandidateSession.new(cookies)
    end

    def candidate_session=(val)
      cookies.signed[:candidate_session] = val
    end

    def reset_candidate_session
      cookies.signed[:candidate_session]
    end

  private

    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def load_session
      resume_session
    end

    def find_session_by_cookie
      Session.find_by(id: candidate_session["session_id"]) if candidate_session["session_id"]
    end

    # Create new session
    #
    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        Current.user = user
        CandidateSession.new(cookies).set("session_id", session.id)
      end
    end

    # Destroy session
    #
    def terminate_session
      Current.session&.destroy
      reset_candidate_session
    end
  end
end
