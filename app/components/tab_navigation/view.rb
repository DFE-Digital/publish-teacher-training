# frozen_string_literal: true

module TabNavigation
  class View < ApplicationComponent
    attr_reader :items

    def initialize(items:, classes: [], html_attributes: {})
      super(classes: classes, html_attributes: html_attributes)
      @items = items
    end
  end
end
