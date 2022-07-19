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
      return if %i[draft empty rolled_over].include? course.content_status

      errors.add(:course_is_rollable?, message: I18n.t("activemodel.errors.models.publish/course_rollover_form.course_is_not_rollable"))
    end
  end
end
