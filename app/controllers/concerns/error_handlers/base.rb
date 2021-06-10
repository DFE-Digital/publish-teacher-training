module ErrorHandlers
  module Base
    extend ActiveSupport::Concern

    included do
      rescue_from(StandardError) do |e|
        raise e unless Settings.render_json_errors
        Sentry.capture_exception(e)
        render_json_error(status: 500)
      end

      rescue_from(ActiveRecord::RecordNotFound) { render_json_error(status: 404) }
    end

  private

    def render_json_error(status:, resource: nil, message: nil)
      if resource.nil?
        render json: error_hash(status, message), status: status
      else
        render jsonapi_errors: resource.errors, status: status
      end
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
end
