# frozen_string_literal: true

module CourseFilters
  class ApplicationsOpenFilter < BaseFilter
    def call(scope)
      scope.application_status_open
    end

    def add_filter?
      filter[:applications_open].to_s.downcase == 'true'
    end
  end
end
