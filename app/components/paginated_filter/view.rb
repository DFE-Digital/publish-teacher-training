# frozen_string_literal: true

module PaginatedFilter
  class View < ViewComponent::Base
    attr_reader :filters, :collection, :filter_label

    renders_one :filter_actions

    def initialize(filters:, collection:, filter_label:)
      @filters = filters
      @collection = collection
      @filter_label = filter_label
    end
  end
end
