# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendWeeklyEmailAlertsJob do
  describe "#perform" do
    it "calls MatchCoursesToEmailAlertsService when feature flag is active" do
      FeatureFlag.activate(:email_alerts)

      allow(Find::MatchCoursesToEmailAlertsService).to receive(:call)

      described_class.new.perform

      expect(Find::MatchCoursesToEmailAlertsService).to have_received(:call).with(since: be_within(1.second).of(1.week.ago))
    end

    it "does not call the service when feature flag is inactive" do
      FeatureFlag.deactivate(:email_alerts)

      allow(Find::MatchCoursesToEmailAlertsService).to receive(:call)

      described_class.new.perform

      expect(Find::MatchCoursesToEmailAlertsService).not_to have_received(:call)
    end
  end
end
