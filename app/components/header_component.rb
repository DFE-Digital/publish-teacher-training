# frozen_string_literal: true

class HeaderComponent < ApplicationComponent
  renders_many :navigation_items, 'NavigationItemComponent'

  renders_one :phase_banner_text, ->(text) { text }

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
      colour:
    }
  end

  def colour
    {
      development: 'grey',
      production: 'blue',
      review: 'purple',
      sandbox: 'purple',
      staging: 'red',
      qa: 'orange'
    }.fetch(Settings.environment.name.to_sym, 'grey')
  end

  class NavigationItemComponent < ApplicationComponent
    attr_reader :text, :href

    def initialize(text, href, classes: [], html_attributes: {})
      super(classes:, html_attributes:)

      @text = text
      @href = href
    end
  end
end
