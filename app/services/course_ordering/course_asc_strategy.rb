# frozen_string_literal: true

module CourseOrdering
  class CourseAscStrategy < BaseStrategy
    def order(scope)
      scope.ascending_course_canonical_order
    end
  end
end
