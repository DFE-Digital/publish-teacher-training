module Find
  module Courses
    module ActiveFilters
      class View < ViewComponent::Base
        attr_reader :search_form, :search_params

        delegate :active_filters, to: :search_form

        def initialize(search_form:)
          @search_form = search_form
          @search_params = search_form.search_params || {}

          super
        end

        def render?
          @search_form.active_filters.present?
        end
      end
    end
  end
end
