# frozen_string_literal: true

module Publish
  class CourseWithdrawalForm < BaseCourseForm
    alias course model

    FIELDS = %i[
      confirm_course_code
    ].freeze

    attr_accessor(*FIELDS)

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
      NotificationService::CourseWithdrawn.call(course:)
    end

    def compute_fields
      {}
    end
  end
end
