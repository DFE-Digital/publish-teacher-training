# frozen_string_literal: true

module CourseFilters
  class FundingTypesFilter < BaseFilter
    def call(scope)
      scope.with_funding_types(filter[:funding_type].split(','))
    end

    def add_filter?
      filter[:funding_type].present?
    end
  end
end
