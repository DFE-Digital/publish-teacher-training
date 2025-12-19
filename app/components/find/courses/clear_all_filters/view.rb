module Find
  module Courses
    module ClearAllFilters
      class View < ViewComponent::Base
        attr_reader :search_form, :search_params, :html_class

        delegate :active_filters, to: :search_form

        def initialize(search_form:, html_class: "app-c-filter-summary__clear-filters")
          @search_form = search_form
          @search_params = search_form.search_params || {}
          @html_class = html_class

          super
        end

        def render?
          @search_form.active_filters.present?
        end
      end
    end
  end
end
