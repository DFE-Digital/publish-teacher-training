# frozen_string_literal: true

class WebCourseSearchService < CourseSearchService
  def ordering_strategy
    @ordering_strategy ||= CourseOrdering::Strategy.find(
      sort:,
      default: :default_ordering
    ).new(course_search_service: self)
  end

  def with_course_type(scope)
    scope.with_course_type(course_type)
  end
end
