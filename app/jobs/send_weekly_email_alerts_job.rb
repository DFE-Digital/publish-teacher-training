# frozen_string_literal: true

class SendWeeklyEmailAlertsJob < ApplicationJob
  def perform
    return unless FeatureFlag.active?(:email_alerts)

    Find::MatchCoursesToEmailAlertsService.call(since: 1.week.ago)
  end
end
