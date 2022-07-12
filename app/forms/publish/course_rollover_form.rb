module Publish
  class CourseRolloverForm
    include ActiveModel::Model

    attr_accessor :course

    def initialize(course)
      @course = course
    end

    validate :course_is_draft

    def save!
      valid?
    end

  private

    def course_is_draft
      return if @course.content_status == :draft

      errors.add(:course_is_draft, message: "Course must have draft status")
    end
  end
end
