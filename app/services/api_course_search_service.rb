# frozen_string_literal: true

class APICourseSearchService < CourseSearchService
  def course_order(outer_scope)
    outer_scope.order('course.created_at': :asc)
  end

  def filter_by_degree_type(scope)
    scope # we want to return all course types in the API
  end
end
