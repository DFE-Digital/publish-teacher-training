# frozen_string_literal: true

class EmailAlertMailerJob < ApplicationJob
  def perform(email_alert_id, course_ids)
    alert = Candidate::EmailAlert.find(email_alert_id)
    courses = Course.includes(:provider)
                    .with_latest_published_enrichment
                    .where(id: course_ids)
                    .order("course_enrichment.last_published_timestamp_utc DESC")

    return if alert.unsubscribed_at.present?
    return if courses.empty?

    EmailAlertMailer.weekly_digest(alert, courses).deliver_now
    alert.touch(:last_sent_at)
  end
end
