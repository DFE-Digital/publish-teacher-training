# frozen_string_literal: true

module CourseFilters
  class DegreeGradesFilter < BaseFilter
    def call(scope)
      scope = scope.with_degree_grades(degree_grades_accepted) if degrees_accepted?
      scope = scope.with_degree_grades(degree_grades) if degree_grades.any?
      scope
    end

    def add_filter?
      degrees_accepted? || degree_grades.any?
    end

    def degrees_accepted?
      filter[:degree_required].present?
    end

    def degree_grades_accepted
      return [] unless degrees_accepted?

      degree_required_parameter = filter[:degree_required].to_sym

      accepted_degrees = {
        show_all_courses: 'two_one,two_two,third_class,not_required',
        two_two: 'two_two,third_class,not_required',
        third_class: 'third_class,not_required',
        not_required: 'not_required'
      }

      (accepted_degrees[degree_required_parameter] || accepted_degrees[:show_all_courses]).split(',')
    end

    def degree_grades
      return [] if filter[:degree_grade].blank?
      return [] unless filter[:degree_grade].is_a?(String)

      filter[:degree_grade].split(',')
    end
  end
end
