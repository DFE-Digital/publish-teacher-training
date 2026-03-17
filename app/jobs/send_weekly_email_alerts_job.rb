# frozen_string_literal: true

class SendWeeklyEmailAlertsJob < ApplicationJob
  def perform(since: 1.week.ago)
    Find::ProcessWeeklyEmailAlertsService.call(since:)
  end
end
