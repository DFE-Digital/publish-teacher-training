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
      # Reloaded so created_at is compared as stored on both sides. The
      # in-memory value from the factory does not always equal the value
      # read back from the database.
      expect(results).to match_collection(
        [new_saved, old_saved].map(&:reload),
        attribute_names: %w[created_at],
      )
    end
  end

  context "when searching by location" do
    let(:london) { build(:location, :london) }
    let!(:london_saved_result) { saved_course_near(london, name: "London Course", provider_name: "London University", distance: 0.0) }
    let!(:lewisham_saved_result) { saved_course_near(lewisham, name: "Lewisham Course", provider_name: "Lewisham University", distance: 6.07) }
    let!(:cambridge_saved_result) { saved_course_near(cambridge, name: "Cambridge Course", provider_name: "Cambridge University", distance: 49.38) }
    let(:lewisham) { build(:location, :lewisham) }
    let(:cambridge) { build(:location, :cambridge) }

    def saved_course_near(location, name:, provider_name:, distance:)
      course = create(:course, name:, provider: create(:provider, provider_name:))
      create(:course_school, course:, gias_school: create(:gias_school, latitude: location.latitude, longitude: location.longitude))

      test_saved_course_wrapper_klass.new(
        create(:saved_course, candidate:, course:),
        minimum_distance_to_search_location: distance,
      )
    end

    context "with location provided" do
      let(:params) { { latitude: london.latitude, longitude: london.longitude } }

      it "returns all saved courses sorted by distance" do
        expect(results).to match_collection(
          [london_saved_result, lewisham_saved_result, cambridge_saved_result],
          attribute_names: %w[minimum_distance_to_search_location],
        )
      end

      it "retains a previous-cycle course without a publishable placement site" do
        previous_cycle_saved = create(
          :saved_course,
          candidate:,
          course: create(
            :course,
            provider: create(:provider, recruitment_cycle: create(:recruitment_cycle, :previous)),
          ),
        )

        expect(results).to include(previous_cycle_saved)
        expect(results.find { it.id == previous_cycle_saved.id }.minimum_distance_to_search_location).to be_nil
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

    it "retains a previous-cycle course without a published enrichment" do
      previous_cycle_saved = create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :fee,
          provider: create(:provider, recruitment_cycle: create(:recruitment_cycle, :previous)),
        ),
      )

      expect(results).to include(previous_cycle_saved)
    end

    it "sorts a previous-cycle course by fee when it has a published enrichment" do
      previous_cycle_saved = create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Mid Course",
          provider: create(
            :provider,
            provider_name: "Mid University",
            recruitment_cycle: find_or_create(:recruitment_cycle, :previous),
          ),
          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 7000)],
        ),
      )

      expect(results.map(&:id)).to eq([cheap_saved.id, previous_cycle_saved.id, expensive_saved.id])
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

    it "retains a previous-cycle course without a published enrichment" do
      previous_cycle_saved = create(
        :saved_course,
        candidate:,
        course: create(
          :course,
          :fee,
          provider: create(:provider, recruitment_cycle: create(:recruitment_cycle, :previous)),
        ),
      )

      expect(results).to include(previous_cycle_saved)
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

  context "when candidate has saved withdrawn courses" do
    let!(:active_saved_course) do
      create(
        :saved_course,
        candidate:,
        course: create(:course, :with_full_time_sites, :published, provider: create(:provider, provider_name: "Active University")),
      )
    end

    before do
      create(
        :saved_course,
        candidate:,
        course: create(:course, :with_full_time_sites, :withdrawn, provider: create(:provider, provider_name: "Withdrawn University")),
      )
    end

    it "excludes withdrawn saved courses from results" do
      expect(results).to match_collection(
        [active_saved_course],
        attribute_names: %w[id],
      )
    end
  end
end
