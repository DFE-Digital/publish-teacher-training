class UpdateCourseSchoolsJob
  include Sidekiq::Job

  def perform(course_id, params)
    course = Course.find(course_id)

    Publish::Schools::UpdateCourseSchoolsService.new(course:, params:).call
    Publish::Schools::UpdateCourseProviderSchoolsService.call(course:, params:)
  end
end
