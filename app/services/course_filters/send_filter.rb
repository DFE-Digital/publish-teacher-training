# frozen_string_literal: true

module CourseFilters
  class SendFilter < BaseFilter
    def call(scope)
      scope.with_send
    end

    def add_filter?
      filter[:send_courses].to_s.downcase == 'true'
    end
  end
end
