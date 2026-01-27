# frozen_string_literal: true

# Captures the candidate's intent to save a course when initiating One Login.
#
# We deliberately only act on the OmniAuth request phase POST, which is CSRF-protected,
# so a cross-site GET cannot poison the session.
class StoreSaveCourseIntent
  SAVE_COURSE_SESSION_KEY = "save_course_id_after_authenticating"
  SAVE_COURSE_RETURN_TO_SESSION_KEY = "save_course_return_to_after_authenticating"
  SAVE_COURSE_RETURN_TO_INVALID_SESSION_KEY = "save_course_return_to_invalid_after_authenticating"

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    store_intent(request, env["rack.session"]) if save_course_intent_request?(request)

    @app.call(env)
  end

private

  def save_course_intent_request?(request)
    request.post? && ["/auth/one-login", "/auth/find-developer"].include?(request.path)
  end

  def store_intent(request, session)
    return unless session

    course_id = request.params["course_id"]
    return_to = request.params["return_to"]

    session[SAVE_COURSE_SESSION_KEY] = course_id

    clear_return_to_state(session)
    store_return_to_state(session, return_to)
  end

  def clear_return_to_state(session)
    session.delete(SAVE_COURSE_RETURN_TO_SESSION_KEY)
    session.delete(SAVE_COURSE_RETURN_TO_INVALID_SESSION_KEY)
  end

  def store_return_to_state(session, return_to)
    return if return_to.blank?

    if safe_results_return_to?(return_to)
      session[SAVE_COURSE_RETURN_TO_SESSION_KEY] = return_to
    else
      session[SAVE_COURSE_RETURN_TO_INVALID_SESSION_KEY] = true
    end
  end

  def safe_results_return_to?(value)
    value.is_a?(String) && value.start_with?("/results") && !value.start_with?("//")
  end
end
