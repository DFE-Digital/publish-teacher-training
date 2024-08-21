# frozen_string_literal: true

class APICourseSearchService < CourseSearchService
  def ordering_strategy
    @ordering_strategy ||= CourseOrdering::Strategy.find(
      sort:,
      default: :api_default_ordering
    ).new(course_search_service: self)
  end

  def with_course_type(scope)
    scope # return all course types in the API
  end
end
