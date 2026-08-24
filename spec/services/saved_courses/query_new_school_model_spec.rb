# frozen_string_literal: true

require "rails_helper"

# Saved-courses location annotation over the canonical course_school -> gias_school
# model, gated by :course_publishing_uses_new_school_model. As with the legacy
# path, saved courses are annotated with distance and sorted, but NOT filtered by
# radius.
RSpec.describe SavedCourses::Query do
  subject(:results) { described_class.call(candidate:, params:) }

  let(:candidate) { create(:candidate) }

  def test_saved_course_wrapper_klass
    @test_saved_course_wrapper_klass ||= Class.new(SimpleDelegator) do
      attr_reader :minimum_distance_to_search_location

      def initialize(saved_course, minimum_distance_to_search_location:)
        super(saved_course)
        @minimum_distance_to_search_location = minimum_distance_to_search_location
      end
    end
  end

  context "when :course_publishing_uses_new_school_model is active" do
    before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }
    after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

    let(:london) { build(:location, :london) }
    let!(:london_saved_result) { saved_course_at(london, provider_name: "London University", distance: 0.0) }
    let!(:lewisham_saved_result) { saved_course_at(lewisham, provider_name: "Lewisham University", distance: 6.07) }
    let!(:cambridge_saved_result) { saved_course_at(cambridge, provider_name: "Cambridge University", distance: 49.38) }
    let(:params) { { latitude: london.latitude, longitude: london.longitude } }
    let(:lewisham) { build(:location, :lewisham) }
    let(:cambridge) { build(:location, :cambridge) }

    def saved_course_at(location, provider_name:, distance:)
      course = create(:course, provider: create(:provider, provider_name:))
      create(
        :course_school,
        course:,
        gias_school: create(:gias_school, latitude: location.latitude, longitude: location.longitude),
      )
      test_saved_course_wrapper_klass.new(
        create(:saved_course, candidate:, course:),
        minimum_distance_to_search_location: distance,
      )
    end

    it "returns all saved courses sorted by distance, without a radius filter" do
      expect(results).to match_collection(
        [london_saved_result, lewisham_saved_result, cambridge_saved_result],
        attribute_names: %w[minimum_distance_to_search_location],
      )
    end

    it "retains a previous-cycle course without a canonical school" do
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
end
