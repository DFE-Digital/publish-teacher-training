# frozen_string_literal: true

require "rails_helper"
require_relative "../results_helper"

# Cross-cuts the active-filter chip extractor and the form's order
# resolution to assert they *agree* on whether an ordering is "default"
# or "applied" for every realistic state. The pre-refactor codebase had
# four sites independently answering "is this a location-based search?"
# with conflicting predicates — that disagreement would silently produce
# wrong chips. These specs lock in consistency end-to-end through the
# real controller and view.
RSpec.describe "Filter chip consistency for order across location states", service: :find do
  include ResultsHelper

  let!(:provider) { create(:provider, provider_name: "Alpha University") }

  let!(:course) do
    create(
      :course,
      :secondary,
      :open,
      :published,
      :with_full_time_sites,
      name: "Mathematics",
      provider: provider,
    )
  end

  before do
    stub_atlantis_geocode_zero_results
  end

  context "with geocoded coordinates" do
    let(:london) { build(:location, :london) }

    before do
      stub_london_location_search
    end

    scenario "no explicit order — no order chip (distance IS the default)" do
      visit find_results_path(
        location: "London, UK",
        latitude: london.latitude,
        longitude: london.longitude,
      )

      expect(page).not_to have_content("Sort by: distance")
      expect(page).not_to have_content("Sort by: Course (a to z)")
    end

    scenario "explicit order=course_name_ascending — chip appears (it is NOT the default for geocoded searches)" do
      visit find_results_path(
        location: "London, UK",
        latitude: london.latitude,
        longitude: london.longitude,
        order: "course_name_ascending",
      )

      expect(page).to have_content("Sort by: Course (a to z)")
    end
  end

  context "with un-geocoded location text" do
    scenario "no explicit order — no order chip (form fell back to course_name_ascending, which IS the default)" do
      visit find_results_path(location: "Atlantis")

      expect(page).not_to have_content("Sort by: distance")
      expect(page).not_to have_content("Sort by: Course (a to z)")
    end

    scenario "explicit order=distance — form normalises away from distance, no 'Sort by: distance' chip surfaces" do
      visit find_results_path(location: "Atlantis", order: "distance")

      expect(page).not_to have_content("Sort by: distance")
    end
  end

  context "with no location at all" do
    scenario "order=course_name_ascending — no chip (this is the default)" do
      visit find_results_path(order: "course_name_ascending")

      expect(page).not_to have_content("Sort by: Course (a to z)")
      expect(page).not_to have_content("Sort by: distance")
    end

    scenario "order=provider_name_ascending — chip appears (not the default)" do
      visit find_results_path(order: "provider_name_ascending")

      expect(page).to have_content(/Sort by: Provider/i)
    end
  end
end
