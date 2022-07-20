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
      return if %i[draft empty rolled_over].include? course.content_status

      errors.add(:course_is_rollable)
    end
  end
end
