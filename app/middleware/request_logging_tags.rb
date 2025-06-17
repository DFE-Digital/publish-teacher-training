class RequestLoggingTags
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    session_id = request.session&.id&.public_id || "-"

    SemanticLogger.tagged(
      request_id: request.request_id,
      session_id: session_id,
    ) do
      @app.call(env)
    end
  end
end
