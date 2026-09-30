# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendWeeklyEmailAlertsJob do
  describe "#perform" do
    it "calls ProcessWeeklyEmailAlertsService with default since" do
      allow(Find::ProcessWeeklyEmailAlertsService).to receive(:call)

      described_class.new.perform

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(
        since: be_within(1.second).of(1.week.ago),
        delivery_week: Time.zone.today.beginning_of_week,
      )
    end

    it "passes a specific since date when provided" do
      allow(Find::ProcessWeeklyEmailAlertsService).to receive(:call)
      specific_date = 2.weeks.ago
      delivery_week = 1.week.ago.to_date.beginning_of_week

      described_class.new.perform(since: specific_date, delivery_week:)

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(since: specific_date, delivery_week:)
    end
  end

  it "runs on Solid Queue's low priority queue" do
    expect(described_class.queue_adapter_name).to eq("solid_queue")
    expect(described_class.new.queue_name).to eq("low_priority")
  end
end
