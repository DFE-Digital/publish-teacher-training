# frozen_string_literal: true

class SendWeeklyEmailAlertsJob < ApplicationJob
  retry_on StandardError, attempts: 0

  def perform(since: 1.week.ago)
    Find::ProcessWeeklyEmailAlertsService.call(since:)
  end
end
