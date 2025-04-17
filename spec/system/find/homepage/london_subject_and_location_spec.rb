# frozen_string_literal: true

require "rails_helper"
require_relative "../results_helper"

RSpec.describe "Search results by subject and location", :js, service: :find do
  include FiltersFeatureSpecsHelper
  include ResultsHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))

    given_courses_exist_in_various_london_locations
    when_i_visit_the_homepage
  end

  scenario "typing invalid location yields no autocomplete suggestions" do
    when_i_start_typing_an_invalid_location
    then_i_see_no_autocomplete_suggestions
  end

  scenario "when I search from the homepage" do
    when_i_start_typing_london_location
    then_i_see_location_suggestions("London, UK")
    and_the_location_suggestions_for_london_is_cached

    when_i_select_the_first_suggestion
    and_i_click_to_search_courses_in_london
    then_i_see_only_courses_within_selected_location_within_london_radius
    and_the_london_radius_is_selected
    and_the_location_search_for_coordinates_is_cached

    and_i_am_on_the_results_page_with_london_location_as_parameter
  end

  scenario "when I search for a specific provider from the homepage" do
    when_i_search_for_a_provider
    and_i_choose_the_first_provider_suggestion
    and_i_click_search
    then_i_see_only_courses_from_that_provider
    and_the_provider_field_is_visible
  end

  scenario "when I search all filters from the homepage" do
    when_i_search_for_math
    and_i_choose_the_first_subject_suggestion

    when_i_start_typing_london_location
    then_i_see_location_suggestions("London, UK")

    when_i_select_the_first_suggestion
    and_i_check_visa_sponsorship_filter_in_the_homepage
    and_i_click_to_search_courses_in_london

    then_i_see_mathematics_courses_in_15_miles_from_london_that_sponsors_visa
    and_i_am_on_the_results_page_with_mathematics_subject_and_london_location_and_sponsor_visa_as_parameter
  end

  def then_i_see_only_courses_within_selected_location_within_london_radius
    expect(results).to have_content(@london_primary_course.name_and_code)
    expect(results).to have_content(@london_mathematics_course.name_and_code)
    expect(results).to have_content(@romford_primary_course.name_and_code)
    expect(results).to have_content(@romford_mathematics_course.name_and_code)

    expect(results).to have_no_content(@watford_primary_course.name_and_code)
    expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
  end

  def and_the_london_radius_is_selected
    expect(page).to have_select("Search radius", selected: "15 miles")
  end

  def and_i_am_on_the_results_page_with_london_location_as_parameter
    and_i_am_on_the_results_page

    expect(search_params).to eq(applications_open: "true", subject_name: "", subject_code: "", location: "London, UK", provider_name: "", provider_code: "")
  end

  def and_i_am_on_the_results_page_with_mathematics_subject_and_london_location_and_sponsor_visa_as_parameter
    and_i_am_on_the_results_page

    expect(search_params).to eq(
      applications_open: "true",
      subject_name: "Mathematics",
      subject_code: "G1",
      location: "London, UK",
      can_sponsor_visa: "true",
      provider_name: "",
      provider_code: "",
    )
  end

private

  def results
    page.first(".app-search-results")
  end

  def search_params
    query_params(URI(page.current_url)).symbolize_keys.except(:utm_source, :utm_medium)
  end

  def stub_london_location_search
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/geocode/json?address=London,%20UK&components=country:UK&key=replace_me&language=en",
    )
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Connection" => "keep-alive",
          "Keep-Alive" => "30",
          "User-Agent" => "Faraday v#{Faraday::VERSION}",
        },
      )
      .to_return(
        status: 200,
        body: file_fixture("google_old_places_api_client/geocode/london.json").read,
        headers: { "Content-Type" => "application/json" },
      )
  end
end
