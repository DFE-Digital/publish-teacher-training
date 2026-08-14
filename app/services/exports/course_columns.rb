# frozen_string_literal: true

module Exports
  module CourseColumns
    def status(course)
      Publish::Courses::StatusTag.token(course).to_s.humanize
    end

    def age_range(course)
      return if course.age_range_in_years.blank?

      course.decorate.age_range
    end
  end
end
