# frozen_string_literal: true

# Captures the candidate's intent to save a course when initiating One Login.
#
# We deliberately only act on the OmniAuth request phase POST, which is CSRF-protected,
# so a cross-site GET cannot poison the session.
class StoreSaveCourseIntent
  SAVE_COURSE_SESSION_KEY = "save_course_id_after_authenticating"

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if save_course_intent_request?(request)
      course_id = request.params["course_id"]
      session = env["rack.session"]

      if session
        session[SAVE_COURSE_SESSION_KEY] = course_id
      end
    end

    @app.call(env)
  end

private

  def save_course_intent_request?(request)
    request.post? && ["/auth/one-login", "/auth/find-developer"].include?(request.path)
  end
end
