# frozen_string_literal: true

class HeaderComponent < ApplicationComponent
  renders_many :navigation_items, "NavigationItemComponent"

  renders_one :phase_banner_text, ->(text) { text }

  renders_one :account_options

  def initialize(service_name:, service_url: nil, current_user: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @service_name = service_name
    @service_url = service_url
    @current_user = current_user
  end

private

  attr_reader :service_name, :current_user

  def service_url
    @service_url || root_path
  end

  def phase_banner_tag
    {
      text: Settings.environment.label,
      colour:,
    }
  end

  def colour
    {
      "development" => "grey",
      "production" => "blue",
      "qa" => "orange",
      "review" => "purple",
      "sandbox" => "purple",
      "staging" => "red",
    }.fetch(Settings.environment.name.to_s, "grey")
  end

  class NavigationItemComponent < ApplicationComponent
    attr_reader :text, :href, :active_when

    def initialize(text, href, active_when: nil, classes: [], html_attributes: {})
      super(classes:, html_attributes:)

      @text = text
      @href = href
      @active_when = active_when
    end
  end
end
