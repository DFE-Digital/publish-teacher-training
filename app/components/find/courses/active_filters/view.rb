module Find
  module Courses
    module ActiveFilters
      class View < ViewComponent::Base
        attr_reader :active_filters, :search_params

        def initialize(active_filters:, search_params: {})
          super

          @active_filters = active_filters
          @search_params = search_params
        end

        def render?
          @active_filters.present?
        end
      end
    end
  end
end
