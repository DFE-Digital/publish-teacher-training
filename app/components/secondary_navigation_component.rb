# frozen_string_literal: true

class SecondaryNavigationComponent < ViewComponent::Base
  renders_many :navigation_items, 'NavigationItemComponent'

  class NavigationItemComponent < ViewComponent::Base
    attr_reader :name, :url

    def initialize(name, url, classes: [], html_attributes: {})
      @name = name
      @url = url

      super(classes:, html_attributes:)
    end

    def call
      content_tag(:li, class: 'app-secondary-navigation__item') do
        link_to name, url, class: 'app-secondary-navigation__link', aria: { current: current_page?(url) && 'page' }
      end
    end
  end
end
