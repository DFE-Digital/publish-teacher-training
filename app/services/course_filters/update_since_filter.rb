# frozen_string_literal: true

module CourseFilters
  class UpdateSinceFilter < BaseFilter
    def call(scope)
      scope.changed_since(filter[:updated_since])
    end

    def add_filter?
      filter[:updated_since].present?
    end
  end
end
