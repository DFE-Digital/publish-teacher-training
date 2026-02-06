# frozen_string_literal: true

require "rails_helper"

RSpec.describe SavedCourses::Query do
  subject(:results) { described_class.call(candidate:, params:) }

  let(:candidate) { create(:candidate) }
  let(:params) { {} }

  def test_saved_course_wrapper_klass
    @test_saved_course_wrapper_klass ||= Class.new(SimpleDelegator) do
      attr_reader :minimum_distance_to_search_location

      def initialize(saved_course, minimum_distance_to_search_location:)
        super(saved_course)
        @minimum_distance_to_search_location = minimum_distance_to_search_location
      end
    end
  end

  context "when default ordering (newest first)" do
    let!(:old_saved) do
      create(
        :saved_course,
        candidate:,
        created_at: 2.days.ago,
        course: create(:course, :with_full_time_sites, name: "Old Course", provider: create(:provider, provider_name: "Alpha University")),
      )
    end

    let!(:new_saved) do
      create(
        :saved_course,
        candidate:,
        created_at: 1.hour.ago,
        course: create(:course, :with_full_time_sites, name: "New Course", provider: create(:provider, provider_name: "Zeta University")),
      )
    end

    it "returns saved courses newest first" do
      expect(results).to match_collection(
        [new_saved, old_saved],
        attribute_names: %w[created_at],
      )
    end
  end

  context "when searching by location" do
    let(:london) { build(:location, :london) }
    let(:lewisham) { build(:location, :lewisham) }
    let(:cambridge) { build(:location, :cambridge) }

    let!(:london_saved_result) do
      test_saved_course_wrapper_klass.new(
        create(
          :saved_course,
          candidate:,
          course: create(
            :course,
            name: "London Course",
            provider: create(:provider, provider_name: "London University"),
            site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
          ),
        ),
        minimum_distance_to_search_location: 0.0,
      )
    end

    let!(:lewisham_saved_result) do
      test_saved_course_wrapper_klass.new(
        create(
          :saved_course,
          candidate:,
          course: create(
            :course,
            name: "Lewisham Course",
            provider: create(:provider, provider_name: "Lewisham University"),
            site_statuses: [create(:site_status, :findable, site: create(:site, latitude: lewisham.latitude, longitude: lewisham.longitude))],
          ),
        ),
        minimum_distance_to_search_location: 6.07,
      )
    end

    let!(:cambridge_saved_result) do
      test_saved_course_wrapper_klass.new(
        create(
          :saved_course,
          candidate:,
          course: create(
            :course,
            name: "Cambridge Course",
            provider: create(:provider, provider_name: "Cambridge University"),
            site_statuses: [create(:site_status, :findable, site: create(:site, latitude: cambridge.latitude, longitude: cambridge.longitude))],
          ),
        ),
        minimum_distance_to_search_location: 49.38,
      )
    end

    context "with default 10 mile radius" do
      let(:params) { { latitude: london.latitude, longitude: london.longitude } }

      it "returns only courses within radius ordered by distance" do
        expect(results).to match_collection(
          [london_saved_result, lewisham_saved_result],
          attribute_names: %w[minimum_distance_to_search_location],
        )
      end
    end

    context "with 50 mile radius" do
      let(:params) { { latitude: london.latitude, longitude: london.longitude, radius: 50 } }

      it "returns courses within 50 miles ordered by distance" do
        expect(results).to match_collection(
          [london_saved_result, lewisham_saved_result, cambridge_saved_result],
          attribute_names: %w[minimum_distance_to_search_location],
        )
      end
    end

    context "when distance ordering requested but no location given" do
      let(:params) { { order: "distance" } }

      it "falls back to newest_first ordering" do
        expect(results).to be_present
      end
    end
  end

  context "when ordering by UK fee ascending" do
    let(:params) { { order: "fee_uk_ascending" } }

    let!(:cheap_saved) do
      create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Cheap Course",
          provider: create(:provider, provider_name: "Alpha University"),
          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)],
        ),
      )
    end

    let!(:expensive_saved) do
      create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Expensive Course",
          provider: create(:provider, provider_name: "Zeta University"),
          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000)],
        ),
      )
    end

    it "returns saved courses ordered by UK fee ascending" do
      expect(results).to match_collection(
        [cheap_saved, expensive_saved],
        attribute_names: %w[course_id],
      )
    end
  end

  context "when ordering by international fee ascending" do
    let(:params) { { order: "fee_intl_ascending" } }

    let!(:cheap_saved) do
      create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Cheap Course",
          provider: create(:provider, provider_name: "Alpha University"),
          enrichments: [build(:course_enrichment, :published, fee_international: 10_000)],
        ),
      )
    end

    let!(:expensive_saved) do
      create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Expensive Course",
          provider: create(:provider, provider_name: "Zeta University"),
          enrichments: [build(:course_enrichment, :published, fee_international: 18_000)],
        ),
      )
    end

    it "returns saved courses ordered by international fee ascending" do
      expect(results).to match_collection(
        [cheap_saved, expensive_saved],
        attribute_names: %w[course_id],
      )
    end
  end

  context "when scoping to candidate" do
    let(:other_candidate) { create(:candidate) }

    let!(:my_saved) do
      create(:saved_course, candidate:, course: create(:course, :with_full_time_sites, provider: create(:provider, provider_name: "Alpha University")))
    end

    before do
      create(:saved_course, candidate: other_candidate, course: create(:course, :with_full_time_sites, provider: create(:provider, provider_name: "Zeta University")))
    end

    it "only returns saved courses for the given candidate" do
      expect(results).to match_collection(
        [my_saved],
        attribute_names: %w[candidate_id],
      )
    end
  end
end
