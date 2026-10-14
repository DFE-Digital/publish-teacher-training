# frozen_string_literal: true

class SendWeeklyEmailAlertsJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :low_priority
  without_auto_retry

  CUTOFF_HOUR = 3

  # Each digest covers the week up to 03:00 on its Friday, so a late run or a
  # retry for that Friday picks up the same courses as the scheduled run.
  def perform(since: nil, delivery_date: EmailAlertMailerJob.delivery_date_for(Time.current))
    before = delivery_date.to_date.in_time_zone.change(hour: CUTOFF_HOUR)

    Find::ProcessWeeklyEmailAlertsService.call(since: since || before - 1.week, before:, delivery_date:)
  end
end
