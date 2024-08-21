# frozen_string_literal: true

module CourseFilters
  class VisaSponsorshipFilter < BaseFilter
    def call(scope)
      scope.can_sponsor_visa
    end

    def add_filter?
      filter[:can_sponsor_visa].to_s.downcase == 'true'
    end
  end
end
