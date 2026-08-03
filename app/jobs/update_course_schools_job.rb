class UpdateCourseSchoolsJob
  include Sidekiq::Job

  def perform(course_id, params)
    course = Course.find(course_id)

    Publish::Schools::UpdateCourseSchoolsService.call(
      course:,
      params:,
      raise_on_missing_provider_schools: false,
    )
  end
end
