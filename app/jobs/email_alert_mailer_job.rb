# frozen_string_literal: true

class EmailAlertMailerJob < ApplicationJob
  def perform(email_alert_id, course_ids)
    alert = EmailAlert.find(email_alert_id)
    return if alert.unsubscribed_at.present?

    courses = Course.where(id: course_ids)
    return if courses.empty?

    EmailAlertMailer.weekly_digest(alert, courses).deliver_now
    alert.update!(last_sent_at: Time.current)
  end
end
