module Find
  module Courses
    module ClearAllFilters
      class View < ViewComponent::Base
        attr_reader :active_filters, :html_class

        def initialize(active_filters:, html_class: "app-c-filter-summary__clear-filters")
          super

          @active_filters = active_filters
          @html_class = html_class
        end

        def render?
          @active_filters.present?
        end
      end
    end
  end
end
