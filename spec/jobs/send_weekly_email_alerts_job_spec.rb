# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendWeeklyEmailAlertsJob do
  describe "#perform" do
    before { allow(Find::ProcessWeeklyEmailAlertsService).to receive(:call) }

    it "covers the week up to 03:00 on the Friday of a scheduled run" do
      travel_to Time.zone.local(2026, 10, 16, 3, 0, 5) do
        described_class.new.perform
      end

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(
        since: Time.zone.local(2026, 10, 9, 3),
        before: Time.zone.local(2026, 10, 16, 3),
        delivery_date: Date.new(2026, 10, 16),
      )
    end

    it "covers the missed Friday's week when a catch-up runs on the Monday" do
      travel_to Time.zone.local(2026, 10, 12, 10) do
        described_class.new.perform
      end

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(
        since: Time.zone.local(2026, 10, 2, 3),
        before: Time.zone.local(2026, 10, 9, 3),
        delivery_date: Date.new(2026, 10, 9),
      )
    end

    it "does not overlap the next Friday when a catch-up runs on the Thursday" do
      travel_to(Time.zone.local(2026, 10, 15, 10)) { described_class.new.perform }
      travel_to(Time.zone.local(2026, 10, 16, 3)) { described_class.new.perform }

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(
        since: Time.zone.local(2026, 10, 2, 3), before: Time.zone.local(2026, 10, 9, 3), delivery_date: Date.new(2026, 10, 9),
      ).ordered
      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(
        since: Time.zone.local(2026, 10, 9, 3), before: Time.zone.local(2026, 10, 16, 3), delivery_date: Date.new(2026, 10, 16),
      ).ordered
    end

    it "keeps the 03:00 cutoff across the clocks going back" do
      described_class.new.perform(delivery_date: Date.new(2026, 10, 30))

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(
        since: Time.zone.local(2026, 10, 23, 3),
        before: Time.zone.local(2026, 10, 30, 3),
        delivery_date: Date.new(2026, 10, 30),
      )
    end

    it "passes a specific since date when provided" do
      specific_date = 2.weeks.ago
      delivery_date = Date.new(2026, 10, 9)

      described_class.new.perform(since: specific_date, delivery_date:)

      expect(Find::ProcessWeeklyEmailAlertsService).to have_received(:call).with(
        since: specific_date,
        before: Time.zone.local(2026, 10, 9, 3),
        delivery_date:,
      )
    end
  end

  it_behaves_like "a Solid Queue job", queue: "low_priority"
end
