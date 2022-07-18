module Publish
  class CourseRolloverForm
    include ActiveModel::Model

    attr_accessor :course

    def initialize(course)
      @course = course
    end

    validate :course_is_rollable?

  private

    def course_is_rollable?
      return if (course.content_status == :draft) || (course.content_status == :empty) || (course.content_status == :rolled_over)

      errors.add(:course_is_rollable, message: I18n.t("activemodel.errors.models.publish/course_rollover_form.course_is_not_rollable"))
    end
  end
end
