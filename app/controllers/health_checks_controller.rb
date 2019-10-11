class HealthChecksController < ActionController::API
  def ping
    render body: "PONG"
  end
end
