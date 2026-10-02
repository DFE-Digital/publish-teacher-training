# frozen_string_literal: true

class SendWeeklyEmailAlertsJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :low_priority
  without_auto_retry

  def perform(since: 1.week.ago, delivery_week: Time.zone.today.beginning_of_week)
    Find::ProcessWeeklyEmailAlertsService.call(since:, delivery_week:)
  end
end
