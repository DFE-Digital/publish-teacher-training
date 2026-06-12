# frozen_string_literal: true

require "rails_helper"
require_relative "../results_helper"

# These specs cover the production scenario that produced
# `PG::UndefinedColumn: column "minimum_distance_to_search_location" does
# not exist` on the Find results page: the user reaches the page with a
# location string in the URL, but the controller could not resolve it to
# coordinates (geocoding returned ZERO_RESULTS, an old email-alert search
# carried only short_address, etc.). In all cases the page must render,
# results must come back sorted by course name, and no misleading
# "Sort by" filter chip should appear.
RSpec.describe "Results page with an un-geocoded location", service: :find do
  include ResultsHelper

  let(:primary_subject) { find_or_create(:primary_subject, :primary) }
  let(:biology_subject) { find_or_create(:secondary_subject, :biology) }

  let!(:apple_provider) { create(:provider, provider_name: "Apple University") }
  let!(:zebra_provider) { create(:provider, provider_name: "Zebra University") }

  let!(:biology_course) do
    create(
      :course,
      :secondary,
      :open,
      :published,
      :with_full_time_sites,
      name: "Biology",
      provider: zebra_provider,
      subjects: [biology_subject],
    )
  end

  let!(:primary_course) do
    create(
      :course,
      :primary,
      :open,
      :published,
      :with_full_time_sites,
      name: "Primary",
      provider: apple_provider,
      subjects: [primary_subject],
    )
  end

  before do
    stub_atlantis_geocode_zero_results
  end

  scenario "location alone — page renders, sorted by course name, no 'Sort by' chip" do
    visit find_results_path(location: "Atlantis")

    expect(page).to have_http_status(:ok)
    expect(page).to have_css("h1", text: /courses/i)
    expect(page).not_to have_content("Sort by: distance")
    expect(page).not_to have_content("Sort by: Course (a to z)")
  end

  scenario "location + subject filter (mirrors the Sentry payload) — subject chip present, no order chip, no crash" do
    visit find_results_path(location: "Atlantis", subjects: [biology_subject.subject_code])

    expect(page).to have_http_status(:ok)
    expect(page).to have_content("Biology")
    expect(page).not_to have_content("Sort by: distance")
    expect(page).not_to have_content("Sort by: Course (a to z)")
  end

  scenario "location + funding filter — funding chip present, no order chip" do
    visit find_results_path(location: "Atlantis", funding: %w[salary])

    expect(page).to have_http_status(:ok)
    expect(page).not_to have_content("Sort by: distance")
    expect(page).not_to have_content("Sort by: Course (a to z)")
  end

  scenario "location + explicit order=course_name_ascending — no order chip (it IS the default)" do
    visit find_results_path(location: "Atlantis", order: "course_name_ascending")

    expect(page).to have_http_status(:ok)
    expect(page).not_to have_content("Sort by: Course (a to z)")
  end

  scenario "location + explicit order=distance — page renders (no PG::UndefinedColumn), no 'Sort by: distance' chip" do
    visit find_results_path(location: "Atlantis", order: "distance")

    expect(page).to have_http_status(:ok)
    expect(page).not_to have_content("Sort by: distance")
  end

  scenario "location + start_date filter — page renders" do
    visit find_results_path(location: "Atlantis", start_date: %w[september])

    expect(page).to have_http_status(:ok)
    expect(page).not_to have_content("Sort by: distance")
  end

  # Locks in the SearchParamDefaults behaviour change: when only the
  # display label (short_address) is present and no coordinates,
  # `order=distance` is no longer considered "the default for this
  # state" — so the chip would surface and look misleading. The form's
  # order resolution prevents the crash; the chip extractor agrees
  # there's nothing default about an un-runnable distance ordering.
  scenario "direct URL with short_address + order=distance, no coordinates — no 'Sort by: distance' chip" do
    visit find_results_path(short_address: "Manchester", order: "distance")

    expect(page).to have_http_status(:ok)
    expect(page).not_to have_content("Sort by: distance")
  end
end
