module Find
  module Authentication
    extend ActiveSupport::Concern

    included do
      before_action :load_session
      helper_method :authenticated?
      helper_method :candidate_session
    end

  private

    # Manage session
    #
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
      Session.find_by(session_key: candidate_session) if candidate_session
    end

    # Create session
    #
    def start_new_session_for(user)
      terminate_session
      user.sessions.create!(session_key: candidate_session, user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
      end
    end

    def request_authentication
      if Current.session
        Current.session.data["return_to_after_authenticating"] = request.url
      end

      redirect_to new_find_sessions_path
    end

    def after_authentication_url
      Current.session.data.delete("return_to_after_authenticating") || find_root_url
    end

    # Destroy session
    #
    def terminate_session
      Current.session&.destroy!
      reset_candidate_session
    end

    # Cookie management
    #
    def candidate_session
      cookies.signed["candidate_session"] ||= new_cookie
      cookies.signed["candidate_session"]
    end

    def reset_candidate_session
      cookies.signed["candidate_session"] = new_cookie
    end

    def new_cookie
      {
        value: SecureRandom.hex(32),
        httponly: true,
        same_site: :lax,
        secure: !Rails.env.in?(%(development test)),
      }
    end
  end
end
