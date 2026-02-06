# frozen_string_literal: true

require "rails_helper"

RSpec.describe SavedCourses::Query do
  let(:candidate) { create(:candidate) }
  let(:london) { build(:location, :london) }
  let(:cambridge) { build(:location, :cambridge) }

  let(:provider_alpha) { create(:provider, provider_name: "Alpha University") }
  let(:provider_zeta) { create(:provider, provider_name: "Zeta University") }

  describe "default ordering (newest first)" do
    let!(:old_saved) do
      create(:saved_course, candidate:, course: create(:course, :with_full_time_sites, provider: provider_alpha), created_at: 2.days.ago)
    end
    let!(:new_saved) do
      create(:saved_course, candidate:, course: create(:course, :with_full_time_sites, provider: provider_zeta), created_at: 1.hour.ago)
    end

    it "returns saved courses newest first by default" do
      results = described_class.call(candidate:)

      expect(results.map(&:id)).to eq([new_saved.id, old_saved.id])
    end
  end

  describe "distance ordering" do
    let!(:nearby_course) do
      create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          name: "Nearby",
          provider: provider_alpha,
          site_statuses: [
            create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude)),
          ],
        ),
      )
    end

    let!(:far_course) do
      create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          name: "Far",
          provider: provider_zeta,
          site_statuses: [
            create(:site_status, :findable, site: create(:site, latitude: cambridge.latitude, longitude: cambridge.longitude)),
          ],
        ),
      )
    end

    it "orders by distance when location is provided" do
      results = described_class.call(
        candidate:,
        params: { latitude: london.latitude, longitude: london.longitude },
      )

      expect(results.map(&:id)).to eq([nearby_course.id, far_course.id])
    end

    it "annotates saved courses with minimum_distance_to_search_location" do
      results = described_class.call(
        candidate:,
        params: { latitude: london.latitude, longitude: london.longitude },
      )

      expect(results.first.minimum_distance_to_search_location).to be_present
      expect(results.first.minimum_distance_to_search_location).to be < 1
    end

    it "falls back to newest_first when distance is requested but no location" do
      results = described_class.call(
        candidate:,
        params: { order: "distance" },
      )

      # Should not raise, should fall back to newest_first
      expect(results.map(&:id)).to be_present
    end

    it "shows all saved courses regardless of distance (no radius filter)" do
      results = described_class.call(
        candidate:,
        params: { latitude: london.latitude, longitude: london.longitude },
      )

      expect(results.map(&:id)).to contain_exactly(nearby_course.id, far_course.id)
    end
  end

  describe "fee ordering" do
    let!(:cheap_course) do
      create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Cheap",
          provider: provider_alpha,
          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000, fee_international: 10_000)],
        ),
      )
    end

    let!(:expensive_course) do
      create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Expensive",
          provider: provider_zeta,
          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000, fee_international: 18_000)],
        ),
      )
    end

    it "orders by UK fee ascending" do
      results = described_class.call(
        candidate:,
        params: { order: "fee_uk_ascending" },
      )

      expect(results.map(&:id)).to eq([cheap_course.id, expensive_course.id])
    end

    it "orders by international fee ascending" do
      results = described_class.call(
        candidate:,
        params: { order: "fee_intl_ascending" },
      )

      expect(results.map(&:id)).to eq([cheap_course.id, expensive_course.id])
    end
  end

  describe "only returns candidate's saved courses" do
    let(:other_candidate) { create(:candidate) }

    let!(:my_saved) do
      create(:saved_course, candidate:, course: create(:course, :with_full_time_sites, provider: provider_alpha))
    end

    before do
      create(:saved_course, candidate: other_candidate, course: create(:course, :with_full_time_sites, provider: provider_zeta))
    end

    it "only returns saved courses for the given candidate" do
      results = described_class.call(candidate:)

      expect(results.map(&:id)).to eq([my_saved.id])
    end
  end
end
