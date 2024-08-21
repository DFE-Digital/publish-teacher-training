# frozen_string_literal: true

module CourseFilters
  class FindableFilter < BaseFilter
    def call(scope)
      scope.findable
    end

    def add_filter?
      filter[:findable].to_s.downcase == 'true'
    end
  end
end
