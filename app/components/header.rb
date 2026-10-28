# frozen_string_literal: true

class Header < ApplicationComponent
  attr_reader :service_name, :current_user, :provider

  include ActiveModel

  def initialize(service_name:, current_user: nil, provider: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)
    @service_name = service_name
    @current_user = current_user
    @provider = provider
  end

  def show_navigation?
    helpers.render_navigation_bar?(provider)
  end

  def navigation_items
    helpers.navigation_items(provider)
  end

  def active_when_for(item)
    [item[:url], item[:additional_url]].compact
  end

  def environment_label
    Settings.environment.label
  end

  def environment_colour
    {
      "development" => "grey",
      "qa" => "orange",
      "review" => "purple",
      "rollover" => "teal",
      "sandbox" => "purple",
      "staging" => "red",
      "unknown-environment" => "yellow",
    }.fetch(Settings.environment.name, "grey")
  end

  def sandbox_mode?
    Settings.environment.name == "sandbox"
  end

  def phase_banner_text
    return unless sandbox_mode?

    "This is a test version of Publish for providers and software vendors"
  end
end
