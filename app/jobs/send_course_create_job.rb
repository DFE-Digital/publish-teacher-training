class SendCourseCreateJob < ApplicationJob
  queue_as :mailer

  def perform(course:, user:)
    CourseCreateEmailMailer.course_create_email(course, user).deliver_now
  end
end
