# frozen_string_literal: true

class EmailAlertMailerJob < ApplicationJob
  queue_as :mailers

  # Only failures where the request never reached Notify. Anything else would
  # risk sending the digest twice, so it fails once and shows in Mission Control.
  retry_on Net::OpenTimeout, SocketError, Errno::ECONNREFUSED, attempts: 3, wait: :polynomially_longer
  # Notify's limit is per minute, so back off long enough for the window to reset.
  retry_on Notifications::Client::RateLimitError, attempts: 5, wait: 1.minute
  fail_without_retry_on Notifications::Client::ServerError, Net::ReadTimeout, ActiveRecord::Deadlocked
  discard_on ActiveRecord::RecordNotFound

  # Digests go out on Fridays. A catch-up run later in the week counts as the
  # previous Friday's digest, so it does not block the next one.
  def self.delivery_date_for(time)
    date = time.in_time_zone.to_date
    date.friday? ? date : date.prev_occurring(:friday)
  end

  def perform(email_alert_id, course_ids, delivery_date = nil)
    alert = Candidate::EmailAlert.find(email_alert_id)
    courses = Course.includes(:provider)
                    .with_latest_published_enrichment
                    .where(id: course_ids)
                    .order("course_enrichment.last_published_timestamp_utc DESC")

    delivery_date ||= self.class.delivery_date_for(enqueued_at || Time.current)

    alert.with_lock do
      return if alert.unsubscribed_at.present?
      return if already_sent?(alert, delivery_date)
      return if courses.empty?

      EmailAlertMailer.weekly_digest(alert, courses).deliver_now
      alert.touch(:last_sent_at)
    end
  end

private

  # Solid Queue marks jobs abandoned by dead workers as failed rather than
  # rerunning them. This stable identity also protects explicit operator retries.
  def already_sent?(alert, delivery_date)
    alert.last_sent_at.present? && alert.last_sent_at >= delivery_date.to_date.in_time_zone
  end
end
