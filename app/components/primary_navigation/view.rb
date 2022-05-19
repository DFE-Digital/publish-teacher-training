module PrimaryNavigation
  class View < GovukComponent::Base
    attr_reader :items

    def initialize(items:)
      @items = items.compact
    end

    def item_link(item)
      link_params = { class: "moj-primary-navigation__link" }
      govuk_link_to(item[:name], item[:url], link_params)
    end

    def list_item_classes
      [
        "moj-primary-navigation__item",
      ].compact.join(" ")
    end
  end
end
