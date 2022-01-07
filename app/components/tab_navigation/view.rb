# frozen_string_literal: true

module TabNavigation
  class View < GovukComponent::Base
    attr_reader :items

    def initialize(items:)
      super(classes: classes, html_attributes: html_attributes)
      @items = items
    end
  end
end
