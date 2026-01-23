module Find
  module Courses
    module ClearAllFilters
      class View < ViewComponent::Base
        attr_reader :active_filters, :html_class, :utm_medium

        def initialize(active_filters:, position:, html_class: "app-c-filter-summary__clear-filters")
          super

          @active_filters = active_filters
          @html_class = html_class
          @utm_medium = "clear_all_filters_#{position}"
        end

        UTM_SOURCE = "results".freeze

        def utm_source
          UTM_SOURCE
        end

        def render?
          @active_filters.present?
        end
      end
    end
  end
end
