class UpdateCourseSchoolsJob
  include Sidekiq::Job

  def perform(course_id, school_uuids)
    course = Course.find(course_id)

    Publish::Schools::UpdateCourseSchoolsService.call(
      course:,
      school_uuids:,
      raise_on_missing_provider_schools: false,
    )
  end
end
