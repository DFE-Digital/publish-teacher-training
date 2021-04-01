# frozen_string_literal: true

module TabNavigation
  class View < GovukComponent::Base
    attr_reader :items

    def initialize(items:)
      @items = items
    end
  end
end
