module Publish
  class CourseWithdrawalForm < BaseModelForm
    alias_method :course, :model

    FIELDS = %i[
      confirm_course_code
    ].freeze

    attr_accessor(*FIELDS)

    validate :course_code_is_correct

    def save!
      if valid?
        course.withdraw
      else
        false
      end
    end

  private

    def compute_fields
      course.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def course_code_is_correct
      return if course.course_code == confirm_course_code

      errors.add(:confirm_course_code, :invalid_code, course_code: course.course_code)
    end
  end
end
