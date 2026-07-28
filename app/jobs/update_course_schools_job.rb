class UpdateCourseSchoolsJob
  include Sidekiq::Job

  def perform(course_id, params, options = {})
    course = Course.find(course_id)
    transactional = options.fetch("transactional", false)

    Publish::Schools::UpdateCourseSchoolsService.call(course:, params:, transactional:)
  end
end
