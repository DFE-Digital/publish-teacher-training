# frozen_string_literal: true

module Errorable
  extend ActiveSupport::Concern

  def not_found
    respond_to do |format|
      format.any { render status: :not_found, template: "errors/not_found" }
    end
  end

  def forbidden
    respond_to do |format|
      format.any { render status: :forbidden, template: "errors/forbidden" }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.any { render status: :internal_server_error, template: "errors/internal_server_error" }
    end
  end
end
