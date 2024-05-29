# frozen_string_literal: true

module Publish
  class CourseSubjectsForm < BaseCourseForm
    alias subject_ids params

    def initialize(model, params: {})
      @previous_subject_names = model.course_subjects.map { |cs| cs.subject.subject_name }
      @previous_course_name = model.name
      super
    end

    private

    attr_reader :previous_subject_names, :previous_course_name

    def valid?
      super && assign_subjects_service.errors.none?
    end

    def compute_fields
      {}
    end

    def after_successful_save_action
      return if (previous_course_name == course.name) && (previous_subject_names == course.subjects.map(&:subject_name))

      NotificationService::CourseSubjectsUpdated.call(
        course:,
        previous_subject_names:,
        previous_course_name:
      )
    end

    def assign_subjects_service
      @assign_subjects_service ||= ::Courses::AssignSubjectsService.call(course:, subject_ids:)
    end

    def save_action
      if assign_subjects_service.save
        after_successful_save_action
        true
      else
        false
      end
    end
  end
end
