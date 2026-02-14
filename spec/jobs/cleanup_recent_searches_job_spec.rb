# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleanupRecentSearchesJob do
  describe "#perform" do
    it "permanently deletes discarded searches older than 1 day" do
      old_discarded = create(:recent_search)
      old_discarded.discard
      old_discarded.update_column(:discarded_at, 2.days.ago)

      described_class.new.perform

      expect(RecentSearch.with_discarded.find_by(id: old_discarded.id)).to be_nil
    end

    it "does not delete recently discarded searches" do
      recent_discarded = create(:recent_search)
      recent_discarded.discard

      described_class.new.perform

      expect(RecentSearch.with_discarded.find_by(id: recent_discarded.id)).to be_present
    end

    it "permanently deletes all searches not updated in 30 days" do
      stale_kept = create(:recent_search, updated_at: 31.days.ago)

      described_class.new.perform

      expect(RecentSearch.with_discarded.find_by(id: stale_kept.id)).to be_nil
    end

    it "does not delete recently updated kept searches" do
      fresh = create(:recent_search, updated_at: 1.day.ago)

      described_class.new.perform

      expect(RecentSearch.find_by(id: fresh.id)).to be_present
    end

    it "deletes stale discarded searches even if discarded_at is recent" do
      stale_discarded = create(:recent_search)
      stale_discarded.discard
      stale_discarded.update_column(:updated_at, 31.days.ago)

      described_class.new.perform

      expect(RecentSearch.with_discarded.find_by(id: stale_discarded.id)).to be_nil
    end
  end
end
