module ResponseErrorHandler
  extend ActiveSupport::Concern

private

  def render_json_error(code: nil, message:, status: :internal_server_error)
    render json: { code: code, error: message }.compact, status: status
  end
end
