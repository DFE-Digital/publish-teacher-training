# frozen_string_literal: true

class EmailAlertMailerJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :mailers

  # Only failures where Notify has not accepted the email. Anything else would
  # risk sending the digest twice, so it fails once and shows in Mission Control.
  retry_on(
    Notifications::Client::ServerError,
    Notifications::Client::RateLimitError,
    Net::OpenTimeout,
    Net::ReadTimeout,
    attempts: 3,
    wait: :polynomially_longer,
  )

  def perform(email_alert_id, course_ids)
    alert = Candidate::EmailAlert.find(email_alert_id)
    courses = Course.includes(:provider)
                    .with_latest_published_enrichment
                    .where(id: course_ids)
                    .order("course_enrichment.last_published_timestamp_utc DESC")

    return if alert.unsubscribed_at.present?
    return if already_sent?(alert)
    return if courses.empty?

    EmailAlertMailer.weekly_digest(alert, courses).deliver_now
    alert.touch(:last_sent_at)
  end

private

  # Solid Queue runs a job again if its worker dies mid-run.
  def already_sent?(alert)
    enqueued_at.present? && alert.last_sent_at.present? && alert.last_sent_at >= enqueued_at
  end
end
