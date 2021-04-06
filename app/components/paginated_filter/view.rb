# frozen_string_literal: true

module PaginatedFilter
  class View < ViewComponent::Base
    attr_reader :filters, :collection

    with_content_areas :filter_actions

    def initialize(filters:, collection:)
      @filters = filters
      @collection = collection
    end
  end
end
