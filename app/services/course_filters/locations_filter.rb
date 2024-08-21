# frozen_string_literal: true

module CourseFilters
  class LocationsFilter < BaseFilter
    def call(scope)
      scope.within(
        filter[:radius],
        origin: [filter[:latitude], filter[:longitude]]
      )
    end

    def add_filter?
      filter.key?(:latitude) &&
        filter.key?(:longitude) &&
        filter.key?(:radius)
    end
  end
end
