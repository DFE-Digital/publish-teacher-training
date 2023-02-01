# frozen_string_literal: true

module Errorable
  extend ActiveSupport::Concern

  def not_found
    render status: :not_found, template: 'errors/not_found'
  end

  def forbidden
    render status: :forbidden, template: 'errors/forbidden'
  end

  def internal_server_error
    render status: :internal_server_error, template: 'errors/internal_server_error'
  end
end
