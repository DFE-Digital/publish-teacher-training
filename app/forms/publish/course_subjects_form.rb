module Publish
  class CourseSubjectsForm < BaseCourseForm
    alias_method :subject_ids, :params

    def initialize(model, params: {})
      @previous_subject_names = model.subjects.map(&:subject_name)
      @previous_course_name = model.name
      super
    end

  private

    attr_reader :previous_subject_names, :previous_course_name

    def valid?
      super && assign_subjects_service.valid?
    end

    def compute_fields
      {}
    end

    def after_successful_save_action
      return if (previous_course_name == course.name) && (previous_subject_names == course.subjects.map(&:subject_name))

      NotificationService::CourseSubjectsUpdated.call(
        course: course,
        previous_subject_names: previous_subject_names,
        previous_course_name: previous_course_name,
      )
    end

    def assign_subjects_service
      @assign_subjects_service ||= ::Courses::AssignSubjectsService.call(course: course, subject_ids: subject_ids)
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
