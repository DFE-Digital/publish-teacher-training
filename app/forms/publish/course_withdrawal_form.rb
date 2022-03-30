module Publish
  class CourseWithdrawalForm < BaseCourseForm
    alias_method :course, :model

    FIELDS = %i[
      confirm_course_code
    ].freeze

    attr_accessor(*FIELDS)

    validate :course_code_is_correct

    def save!
      if valid?
        course.withdraw
        after_successful_save_action
        true
      else
        false
      end
    end

  private

    def after_successful_save_action
      NotificationService::CourseWithdrawn.call(course: course)
    end

    def compute_fields
      course.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def course_code_is_correct
      return if course.course_code == confirm_course_code

      errors.add(:confirm_course_code, :invalid_code, course_code: course.course_code)
    end
  end
end
