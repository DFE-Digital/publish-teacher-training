# frozen_string_literal: true

class Header::View < ApplicationComponent
  attr_reader :service_name, :current_user

  include ActiveModel

  def initialize(service_name:, current_user: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)
    @service_name = service_name
    @current_user = current_user
  end

  def environment_header_class
    "app-header--#{Settings.environment.name}"
  end
end
