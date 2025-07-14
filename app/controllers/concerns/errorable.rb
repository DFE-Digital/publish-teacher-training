# frozen_string_literal: true

module Errorable
  extend ActiveSupport::Concern
  # **`rescue_from` are run bottom to top
  included do
    rescue_from StandardError, with: :internal_server_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::UnknownFormat, with: :not_acceptable
  end

  def not_found
    respond_to do |format|
      format.any { render status: :not_found, formats: [:html], template: "errors/not_found" }
    end
  end
  alias_method :render_not_found, :not_found

  def forbidden
    respond_to do |format|
      format.any { render status: :forbidden, formats: [:html], template: "errors/forbidden" }
    end
  end

  def not_acceptable
    respond_to do |format|
      format.any { render status: :not_acceptable, formats: [:html], template: "errors/not_acceptable" }
    end
  end

  # This method is called when /500.xxx is requested
  # an in that case, no error is passed to the
  # method
  def internal_server_error(error = nil)
    if error
      Sentry.capture_exception(error)
      raise error if Rails.env.development? || Rails.env.test?
    end

    respond_to do |format|
      format.any { render status: :internal_server_error, formats: [:html], template: "errors/internal_server_error" }
    end
  end
end
