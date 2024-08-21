# frozen_string_literal: true

module CourseFilters
  class SalaryFilter < BaseFilter
    def call(scope)
      scope.with_salary
    end

    def add_filter?
      filter[:funding] == 'salary'
    end
  end
end
