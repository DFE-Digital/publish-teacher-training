# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendWeeklyEmailAlertsJob do
  describe "#perform" do
    it "calls ProcessWeeklyEmailAlertsService with default since" do
      allow(Find::ProcessWeeklyEmailAlertsService).to receive(:call)

      described_class.new.perform

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(
        since: be_within(1.second).of(1.week.ago),
        delivery_date: EmailAlertMailerJob.delivery_date_for(Time.current),
      )
    end

    it "passes a specific since date when provided" do
      allow(Find::ProcessWeeklyEmailAlertsService).to receive(:call)
      specific_date = 2.weeks.ago
      delivery_date = Date.new(2026, 10, 9)

      described_class.new.perform(since: specific_date, delivery_date:)

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(since: specific_date, delivery_date:)
    end
  end

  it_behaves_like "a Solid Queue job", queue: "low_priority"
end
