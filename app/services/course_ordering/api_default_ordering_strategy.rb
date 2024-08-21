# frozen_string_literal: true

module CourseOrdering
  class APIDefaultOrderingStrategy < BaseStrategy
    def order(scope)
      scope.order('course.id ASC')
    end
  end
end
