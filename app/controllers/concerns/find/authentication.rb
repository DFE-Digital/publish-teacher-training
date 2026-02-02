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

    def omniauth
      request.env["omniauth.auth"]
    end

    # Create session
    #
    def start_new_session_for(user, oauth)
      ::Authentication.transaction do
        terminate_session

        user.sessions.create!(session_key: candidate_session, id_token: oauth.credentials.id_token, user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
          Current.session = session
        end
      end
    end

    def request_authentication
      session["return_to_after_authenticating"] = request.url

      respond_to do |format|
        format.html do
          flash[:sign_in] = "You must sign in to visit that page."
          flash[:sign_in_reason] = reason_for_request
          redirect_to find_root_path
        end

        format.json do
          session["flash_sign_in_reason"] = reason_for_request_from_json

          redirect_path = find_root_path
          if reason_for_request_from_json == :save_course && params[:course_id].present?
            return_to = safe_results_return_to_from_referer
            redirect_path = sign_in_find_candidate_saved_courses_path(course_id: params[:course_id], return_to: return_to.presence)
          end

          render json: { redirect: redirect_path }, status: :unauthorized
        end
      end
    end

    def reason_for_request_from_json
      if request.path.start_with?("/candidate/saved-courses")
        :save_course
      else
        :general
      end
    end

    def safe_results_return_to_from_referer
      # When the results-page "Save" button is clicked while unauthenticated, the request comes in
      # as JSON (fetch). We respond with a redirect URL that the browser follows.
      #
      # This helper derives a safe `return_to` from the HTTP Referer so users can be sent back to
      # the same results page after signing in.
      #
      # Security notes:
      # - We only allow same-host URLs to avoid open redirect issues.
      # - We only allow paths under `/results` to avoid redirecting to arbitrary internal pages.
      # - Invalid/absent referers simply result in no `return_to` being used.
      return nil if request.referer.blank?

      uri = URI.parse(request.referer)
      return nil unless uri.host == request.host

      path = uri.request_uri
      return nil unless path.is_a?(String) && path.start_with?("/results")

      path
    rescue URI::InvalidURIError
      nil
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
      cookies.signed[cookie_name] ||= new_cookie
      cookies.signed[cookie_name]
    end

    def reset_candidate_session
      cookies.signed[cookie_name] = new_cookie
    end

    def new_cookie
      {
        value: SecureRandom.hex(32),
        httponly: true,
        same_site: :lax,
        secure: !Rails.env.in?(%(development test)),
      }
    end

    def cookie_name
      Settings.cookies.candidate_session.name
    end
  end
end
