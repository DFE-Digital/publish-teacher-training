# frozen_string_literal: true

module CourseOrdering
  class CourseDescStrategy < BaseStrategy
    def order(scope)
      scope.descending_course_canonical_order
    end
  end
end
