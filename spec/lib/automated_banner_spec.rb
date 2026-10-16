# frozen_string_literal: true

require "rails_helper"

RSpec.describe AutomatedBanner do
  def next_year = Find::CycleTimetable.current_year + 1

  describe "apply opens soon" do
    def apply_opens_soon = described_class.all.find { it.id == "apply_opens_soon" }

    it "is scheduled for the moment Find opens", travel: 1.hour.before(find_opens) do
      expect(described_class.scheduled.map(&:id)).to include("apply_opens_soon")
      expect(apply_opens_soon).to have_attributes(
        published_at: Find::CycleTimetable.find_opens,
        expired_at: Find::CycleTimetable.apply_opens,
      )
    end

    it "is active on Find until Apply opens", travel: 1.hour.after(find_opens) do
      expect(described_class.active(interface: :find).map(&:id)).to eq(%w[apply_opens_soon])
      expect(described_class.active(interface: :publish)).to be_empty
    end

    it "moves to the next cycle once Apply has opened", travel: 1.hour.after(apply_opens) do
      expect(described_class.active(interface: :find)).to be_empty
      expect(apply_opens_soon.published_at).to eq(Find::CycleTimetable.find_opens(next_year))
    end

    it "counts the days left until Apply opens", travel: 1.hour.after(find_opens) do
      days = (Find::CycleTimetable.apply_opens.to_date - Date.current).to_i

      expect(apply_opens_soon.body).to include("in #{days} days")
    end

    it "previews the count it will show when it is published", travel: 1.hour.before(find_opens) do
      days = (Find::CycleTimetable.apply_opens.to_date - Find::CycleTimetable.find_opens.to_date).to_i

      expect(apply_opens_soon.body).to include("in #{days} days")
    end
  end

  describe "rollover has started" do
    def rollover_started = described_class.all.find { it.id == "rollover_started" }

    let!(:next_cycle) { find_or_create(:recruitment_cycle, :next) }

    it "is scheduled for the day rollover is available to providers" do
      expect(described_class.scheduled.map(&:id)).to include("rollover_started")
      expect(rollover_started).to have_attributes(
        published_at: next_cycle.available_in_publish_from.in_time_zone.beginning_of_day,
        expired_at: Find::CycleTimetable.find_opens(next_year),
      )
    end

    it "is active on Publish until Find opens for the new cycle" do
      travel_to next_cycle.available_in_publish_from.in_time_zone.beginning_of_day do
        expect(described_class.active(interface: :publish).map(&:id)).to eq(%w[rollover_started])
        expect(described_class.active(interface: :find)).to be_empty
      end
    end

    it "stays active through the night before Find opens" do
      travel_to 1.hour.before(Find::CycleTimetable.find_opens(next_year)) do
        expect(described_class.active(interface: :publish).map(&:id)).to eq(%w[rollover_started])
      end
    end

    it "is gone once Find has opened" do
      travel_to 1.hour.after(Find::CycleTimetable.find_opens(next_year)) do
        expect(rollover_started).to be_nil
      end
    end

    it "is absent while the next cycle has no rollover date" do
      next_cycle.update!(available_in_publish_from: nil)

      expect(rollover_started).to be_nil
    end
  end

  it "refuses an id it does not know" do
    expect { described_class.find("nonsense") }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
