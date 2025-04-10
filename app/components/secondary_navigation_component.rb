# frozen_string_literal: true

class SecondaryNavigationComponent < ViewComponent::Base
  renders_many :navigation_items, "NavigationItemComponent"

  class NavigationItemComponent < ViewComponent::Base
    def initialize(name, url, current: nil, classes: [], html_attributes: {})
      @name = name
      @url = url
      @current = current

      super(classes:, html_attributes:)
    end

    def call
      content_tag(:li, class: "app-secondary-navigation__item") do
        link_to name, url, class: "app-secondary-navigation__link", aria: { current: current? }
      end
    end

  private

    attr_reader :name, :url, :current

    def current?
      (current || current_page?(url)) && "page"
    end
  end
end
