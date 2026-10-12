# frozen_string_literal: true

class UpdateCourseSchoolsJob < ApplicationJob
  queue_as :default
  without_auto_retry

  def perform(course_id, school_uuids)
    course = Course.find(course_id)

    Publish::Schools::UpdateCourseSchoolsService.call(
      course:,
      school_uuids:,
      raise_on_missing_provider_schools: false,
    )
  end
end
