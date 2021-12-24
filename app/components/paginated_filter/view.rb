# frozen_string_literal: true

module PaginatedFilter
  class View < ViewComponent::Base
    attr_reader :filter_params, :collection

    def initialize(filter_params:, collection:)
      @filter_params = filter_params
      @collection = collection
    end

    def filters
      filter_params.slice(*allowed_search_params_keys)
    end

  private

    def allowed_search_params_keys
      {
        User: %i[text_search user_type],
        Provider: %i[provider_search course_search],
        Allocation: [:text_search],
      }[collection.klass.name.to_sym]
    end
  end
end
