class SendCourseUpdateJob < ApplicationJob
  queue_as :mailer

  def perform(course:, attribute_name:, original_value:, updated_value:, recipient:)
    CourseUpdateEmailMailer.course_update_email(
      course: course,
      attribute_name: attribute_name,
      original_value: original_value,
      updated_value: updated_value,
      recipient: recipient
    ).deliver_now
  end
end
