# frozen_string_literal: true

require "rails_helper"
require_relative "../results_helper"

# Reproduces the report: a user searches for a subject + postcode on the
# homepage, lands on the results page, picks "Sort by Course name (a to z)"
# from the dropdown — but no "Sort by" chip appears in the active filters.
# A second click on the same sort option works.
#
# Root cause: the previous render's hidden `previous_location_category`
# was captured as "regional", while the geocoder returns "postal_code"
# address_types on this request — making the location category effectively
# "locality". SearchForm#order then sees location_category_changed? as true
# and silently drops the explicit user choice, resetting the order to the
# location default ("distance"). The chip extractor then sees
# order == default → no chip surfaces.
#
# The deeper question is whether `location_category_changed?` should ever
# override an explicit user sort. This spec locks in the answer: no.
RSpec.describe "Sort choice respected after location category drift", service: :find do
  include ResultsHelper

  let!(:provider) { create(:provider, provider_name: "Alpha University") }

  let!(:mathematics) do
    create(
      :course,
      :secondary,
      :open,
      :published,
      :with_full_time_sites,
      name: "Mathematics",
      provider: provider,
      subjects: [find_or_create(:secondary_subject, :mathematics)],
    )
  end

  before do
    # Geocode result with `postal_code` in address_types → DefaultRadius
    # computes location_category = "locality" on this render.
    allow(Geolocation::Address).to receive(:query).with("BS1 4SB, Bristol").and_return(
      Geolocation::Address.new(
        formatted_address: "Bristol BS1 4SB, UK",
        latitude: 51.4505,
        longitude: -2.5867,
        country: "United Kingdom",
        postal_code: "BS1 4SB",
        postal_town: "Bristol",
        address_types: %w[postal_code],
      ),
    )
  end

  scenario "explicit Sort by course name (a to z) surfaces a chip even when previous_location_category drifted" do
    # Mirrors the exact URL the user lands on after picking Sort from the
    # dropdown — the offending bit is `previous_location_category=regional`
    # while the geocoder reports a locality category for this request.
    visit find_results_path(
      previous_location_category: "regional",
      subject_name: "Mathematics",
      subject_code: "G1",
      location: "BS1 4SB, Bristol",
      order: "course_name_ascending",
      radius: 50,
      subjects: %w[G1],
      minimum_degree_required: "show_all_courses",
    )

    expect(page).to have_http_status(:ok)
    expect(page).to have_content("Sort by: Course (a to z)")
  end
end
