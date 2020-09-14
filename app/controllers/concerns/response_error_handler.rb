module ResponseErrorHandler
  extend ActiveSupport::Concern

private

  def render_json_error(status: 500, message: nil)
    render json: error_hash(status, message), status: status
  end

  def error_hash(status, message = nil)
    {
      errors: [
        {
          status: status,
          title: I18n.t("errors.#{status}.title"),
          detail: I18n.t("errors.#{status}.detail", message: message),
        },
      ],
    }
  end
end
