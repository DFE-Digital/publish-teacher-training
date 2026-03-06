# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendWeeklyEmailAlertsJob do
  describe "#perform" do
    it "calls MatchCoursesToEmailAlertsService" do
      allow(Find::MatchCoursesToEmailAlertsService).to receive(:call)

      described_class.new.perform

      expect(Find::MatchCoursesToEmailAlertsService).to have_received(:call).with(since: be_within(1.second).of(1.week.ago))
    end
  end
end
