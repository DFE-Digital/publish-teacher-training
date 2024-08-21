# frozen_string_literal: true

module CourseOrdering
  class DefaultOrderingStrategy < BaseStrategy
    def order(scope)
      scope
    end
  end
end
