# frozen_string_literal: true

module Courses
  # The course-information lines shared by the Publish and Support course lists:
  # funding, qualification, study mode and start date.
  class InformationLabels
    def initialize(course)
      @course = course
    end

    def funding
      I18n.t("publish.courses.course_table.funding.#{course.funding}")
    end

    def qualification
      course.qualifications_summary
    end

    def study_mode
      course.study_mode_description.capitalize
    end

    def start_date
      return if course.start_date.blank?

      I18n.l(course.start_date.to_date, format: :short)
    end

  private

    attr_reader :course
  end
end
