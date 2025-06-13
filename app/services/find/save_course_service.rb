# frozen_string_literal: true

module Find
  class SaveCourseService
    def self.call(candidate:, course:)
      new(candidate, course).call
    end

    def initialize(candidate, course)
      @candidate = candidate
      @course = course
    end

    def call
      @candidate.saved_courses.find_or_create_by!(course_id: @course.id)
      true
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      Sentry.capture_exception(e)
      false
    end
  end
end
