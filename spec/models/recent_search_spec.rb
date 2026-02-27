# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecentSearch, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:find_candidate).class_name("Candidate") }
  end

  describe "discard" do
    subject(:recent_search) { create(:recent_search) }

    it "supports soft-delete via Discard" do
      recent_search.discard
      expect(recent_search).to be_discarded
    end

    it "can be undiscarded" do
      recent_search.discard
      recent_search.undiscard
      expect(recent_search).not_to be_discarded
    end
  end

  describe "scopes" do
    describe ".active" do
      it "returns only kept records ordered by updated_at desc" do
        old = create(:recent_search, updated_at: 2.days.ago)
        recent = create(:recent_search, updated_at: 1.hour.ago)
        discarded = create(:recent_search)
        discarded.discard

        expect(described_class.active).to eq([recent, old])
      end
    end

    describe ".stale" do
      it "returns records not updated in over 30 days" do
        stale = create(:recent_search, updated_at: 31.days.ago)
        _fresh = create(:recent_search, updated_at: 1.day.ago)

        expect(described_class.stale).to contain_exactly(stale)
      end
    end

    describe ".for_display" do
      it "returns at most 10 active records" do
        create_list(:recent_search, 12)

        expect(described_class.for_display.count).to eq(10)
      end
    end
  end

  describe "validation" do
    it "accepts valid search_attributes keys" do
      recent_search = build(:recent_search, search_attributes: { "funding" => "salary", "level" => "secondary" })

      expect(recent_search).to be_valid
    end

    it "accepts empty search_attributes" do
      recent_search = build(:recent_search, search_attributes: {})

      expect(recent_search).to be_valid
    end

    it "rejects unknown search_attributes keys" do
      recent_search = build(:recent_search, search_attributes: { "bogus_key" => "value" })

      expect(recent_search).not_to be_valid
      expect(recent_search.errors[:search_attributes].first).to include("bogus_key")
    end
  end

  describe "#search_params" do
    it "merges denormalized columns with search_attributes" do
      recent_search = build(
        :recent_search,
        subjects: %w[C1 F1],
        longitude: -1.5,
        latitude: 53.0,
        radius: 20,
        search_attributes: { "funding" => "salary" },
      )

      result = recent_search.search_params

      expect(result).to eq(
        funding: "salary",
        subjects: %w[C1 F1],
        longitude: -1.5,
        latitude: 53.0,
        radius: 20,
      )
    end

    it "omits blank denormalized columns" do
      recent_search = build(:recent_search, search_attributes: { "level" => "primary" })

      result = recent_search.search_params

      expect(result).to eq(level: "primary")
    end
  end
end
