# frozen_string_literal: true

class SendWeeklyEmailAlertsJob < ApplicationJob
  def perform
    Find::MatchCoursesToEmailAlertsService.call(since: 1.week.ago)
  end
end
