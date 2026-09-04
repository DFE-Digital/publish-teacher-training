# frozen_string_literal: true

module Publish
  class CourseRolloverForm
    include ActiveModel::Model

    attr_accessor :course, :course_is_rollable

    def initialize(course)
      @course = course
    end

    validate :course_is_rollable?

  private

    def course_is_rollable?
      return if course.manually_rollable?

      errors.add(:course_is_rollable)
    end
  end
end
