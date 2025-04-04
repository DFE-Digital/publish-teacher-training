# frozen_string_literal: true

class Header < ApplicationComponent
  attr_reader :service_name, :current_user

  include ActiveModel

  def initialize(service_name:, current_user: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)
    @service_name = service_name
    @current_user = current_user
  end

  def colour
    {
      development: "grey",
      production: "blue",
      review: "purple",
      sandbox: "purple",
      staging: "red",
      qa: "orange",
    }.fetch(Settings.environment.name.to_sym, "grey")
  end
end
