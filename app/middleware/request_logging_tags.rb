class RequestLoggingTags
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    session_id = request.session&.id&.public_id || "-"

    # Azure FrontDoor appends the FrontDoor IP address to X-Forwarded-For header
    # So we should use X-Azure-ClientIP header to get the client IP
    # https://learn.microsoft.com/en-us/azure/frontdoor/front-door-http-headers-protocol
    SemanticLogger.tagged(
      request_id: request.request_id,
      session_id: session_id,
      user_agent: request.user_agent,
      remote_ip: request.headers["X-Azure-ClientIP"] || request.remote_ip,
      referrer: request.referrer,
    ) do
      @app.call(env)
    end
  end
end
