module Publish
  class CourseRolloverForm
    include ActiveModel::Model


    attr_accessor :course

    def initialize(course)
      @course = course
    end

    validate :course_is_draft

    def save!
      if valid?
        true
      else
        false
      end
    end

  private

    def course_is_draft
      return if @course.content_status == :draft

      errors.add(:course_is_draft, message: "Hello")
    end

  end
end