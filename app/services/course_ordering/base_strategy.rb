# frozen_string_literal: true

module CourseOrdering
  class BaseStrategy
    attr_reader :course_search_service

    delegate :filter, to: :course_search_service

    def initialize(course_search_service:)
      @course_search_service = course_search_service
    end

    def order(scope)
      raise NotImplementedError, 'Subclasses must implement the #order method'
    end
  end
end
