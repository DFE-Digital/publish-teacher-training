# frozen_string_literal: true

class APICourseSearchService < CourseSearchService
  def default_course_order(outer_scope)
    outer_scope.order('course.id': :asc)
  end

  def filter_by_course_type(scope)
    scope # we want to return all course types in the API
  end
end
