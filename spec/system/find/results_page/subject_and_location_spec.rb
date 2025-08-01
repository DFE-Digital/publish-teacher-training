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
    when_i_visit_the_results_page
  end

  scenario "typing and invalid location has not autocomplete suggestions" do
    when_i_start_typing_an_invalid_location
    then_i_see_no_autocomplete_suggestions
  end

  scenario "when I filter by location" do
    when_i_start_typing_london_location
    then_i_see_location_suggestions("London, UK")
    and_the_location_suggestions_for_london_is_cached

    when_i_select_the_first_suggestion
    and_i_set_the_radius_to_10_miles
    and_the_10_mile_radius_is_selected
    and_i_click_to_search_courses_in_london
    then_i_only_see_courses_within_a_10_mile_radius
    and_the_location_search_for_coordinates_is_cached

    when_i_increase_the_radius_to_15_miles
    and_i_click_search
    then_i_see_courses_up_to_15_miles_distance
    and_the_15_miles_radius_is_selected

    when_i_increase_the_radius_to_20_miles
    and_i_click_search
    then_i_see_courses_up_to_20_miles_distance
    and_the_20_miles_radius_is_selected
  end

  scenario "when I filter by location and subject" do
    when_i_start_typing_london_location
    then_i_see_location_suggestions("London, UK")

    when_i_select_the_first_suggestion
    and_i_set_the_radius_to_10_miles
    and_i_click_to_search_courses_in_london
    then_i_only_see_courses_within_a_10_mile_radius

    and_select_primary_subject
    and_i_click_search
    then_i_see_only_courses_within_selected_location_and_primary_subject_within_a_10_mile_radius
  end

  scenario "when I filter by subject" do
    when_i_search_for_math
    and_i_choose_the_first_subject_suggestion
    and_i_click_search
    then_i_see_only_mathematics_courses
  end

  scenario "when I search by provider" do
    when_i_search_for_a_provider
    and_i_choose_the_first_provider_suggestion
    and_i_click_search
    then_i_see_only_courses_from_that_provider
    and_the_provider_field_is_visible
  end

  scenario "when search results update after filter changes" do
    when_i_search_for_math
    and_i_choose_the_first_subject_suggestion
    and_i_set_the_radius_to_10_miles

    when_i_start_typing_london_location
    then_i_see_location_suggestions("London, UK")

    when_i_select_the_first_suggestion
    and_i_increase_the_radius_to_15_miles
    and_i_click_to_search_courses_in_london

    when_i_filter_by_courses_that_sponsor_visa
    and_i_click_apply_filters

    then_i_see_mathematics_courses_in_15_miles_from_london_that_sponsors_visa
  end

  scenario 'when searching "London, UK" using old location parameters' do
    when_i_search_courses_in_london_using_old_parameters
    then_i_see_courses_up_to_15_miles_distance
    and_the_location_search_for_coordinates_is_cached
    and_london_is_displayed_in_text_field
  end

  def when_i_filter_by_courses_that_sponsor_visa
    check "Only show courses with visa sponsorship", visible: :all
  end

  def and_i_click_apply_filters
    click_link_or_button "Apply filters", match: :first
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def when_i_start_typing_an_invalid_location
    when_i_start_typing_non_existent_city_location
  end

  def when_i_start_typing_non_existent_city_location
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:uk&input=NonExistentCity&key=replace_me&language=en&types=geocode",
    ).with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Connection" => "keep-alive",
        "Keep-Alive" => "30",
        "User-Agent" => "Faraday v#{Faraday::VERSION}",
      },
    ).to_return(status: 200, body: file_fixture("google_old_places_api_client/autocomplete/non_existent_city.json"), headers: { "Content-Type" => "application/json" })

    fill_in "City, town or postcode", with: "NonExistentCity"
  end

  def then_i_see_no_autocomplete_suggestions
    expect(page).to have_css("#location-field__listbox", visible: :hidden)
  end

  def and_the_location_suggestions_for_london_is_cached
    expect(Rails.cache.read("geolocation:suggestions:lon")).to eq(
      [
        {
          name: "London, UK",
          place_id: "ChIJdd4hrwug2EcRmSrV3Vo6llI",
          types: %w[locality political],
        },
      ],
    )
  end

  def and_the_location_search_for_coordinates_is_cached
    expect(Rails.cache.read("geolocation:query:london-uk")).to eq(
      {
        formatted_address: "London, UK",
        latitude: 51.5072178,
        longitude: -0.1275862,
        country: "England",
        types: %w[locality political],
      },
    )
  end

  def when_i_start_typing_london_location
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:uk&input=Lon&key=replace_me&language=en&types=geocode",
    ).with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Connection" => "keep-alive",
        "Keep-Alive" => "30",
        "User-Agent" => "Faraday v#{Faraday::VERSION}",
      },
    ).to_return(status: 200, body: file_fixture("google_old_places_api_client/autocomplete/london.json"), headers: { "Content-Type" => "application/json" })

    fill_in "City, town or postcode", with: "Lon"
  end

  def when_i_select_the_first_suggestion
    page.find_by_id("location-field__option--0").click
  end

  def and_i_click_to_search_courses_in_london
    stub_london_location_search

    and_i_click_search
  end

  def then_i_only_see_courses_within_a_10_mile_radius
    with_retry do
      expect(results).to have_content(@london_primary_course.name_and_code)
      expect(results).to have_content(@london_mathematics_course.name_and_code)

      expect(results).to have_no_content(@romford_primary_course.name_and_code)
      expect(results).to have_no_content(@romford_mathematics_course.name_and_code)
      expect(results).to have_no_content(@watford_primary_course.name_and_code)
      expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
    end
  end

  def and_the_10_mile_radius_is_selected
    expect(page).to have_select("Search radius", selected: "10 miles")
  end

  def and_the_15_miles_radius_is_selected
    expect(page).to have_select("Search radius", selected: "15 miles")
  end

  def and_the_20_miles_radius_is_selected
    expect(page).to have_select("Search radius", selected: "20 miles")
  end

  def and_i_click_search
    click_link_or_button "Search"
  end

  def when_i_increase_the_radius_to_15_miles
    select "15 miles", from: "radius"
  end
  alias_method :and_i_increase_the_radius_to_15_miles, :when_i_increase_the_radius_to_15_miles

  def when_i_set_the_radius_to_10_miles
    select "10 miles", from: "radius"
  end
  alias_method :and_i_set_the_radius_to_10_miles, :when_i_set_the_radius_to_10_miles

  def then_i_see_courses_up_to_15_miles_distance
    with_retry do
      expect(results).to have_content(@london_primary_course.name_and_code)
      expect(results).to have_content(@london_mathematics_course.name_and_code)
      expect(results).to have_content(@romford_primary_course.name_and_code)
      expect(results).to have_content(@romford_mathematics_course.name_and_code)

      expect(results).to have_no_content(@watford_primary_course.name_and_code)
      expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
    end
  end

  def when_i_increase_the_radius_to_20_miles
    select "20 miles", from: "radius"
  end

  def then_i_see_courses_up_to_20_miles_distance
    with_retry do
      expect(results).to have_content(@london_primary_course.name_and_code)
      expect(results).to have_content(@london_mathematics_course.name_and_code)
      expect(results).to have_content(@romford_primary_course.name_and_code)
      expect(results).to have_content(@romford_mathematics_course.name_and_code)
      expect(results).to have_content(@watford_primary_course.name_and_code)
      expect(results).to have_content(@watford_mathematics_course.name_and_code)
    end
  end

  def and_select_primary_subject
    fill_in "Subject", with: "Pri"

    and_i_choose_the_first_subject_suggestion
  end

  def and_i_choose_the_first_subject_suggestion
    page.find('input[name="subject_name"]').native.send_keys(:return)
  end

  def then_i_see_only_courses_within_selected_location_and_primary_subject_within_a_10_mile_radius
    with_retry do
      expect(results).to have_content(@london_primary_course.name_and_code)
      expect(results).to have_no_content(@london_mathematics_course.name_and_code)
      expect(results).to have_no_content(@romford_primary_course.name_and_code)
      expect(results).to have_no_content(@romford_mathematics_course.name_and_code)
      expect(results).to have_no_content(@watford_primary_course.name_and_code)
      expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
    end
  end

  def when_i_search_for_math
    fill_in "Subject", with: "Mat"
  end

  def then_i_see_only_mathematics_courses
    with_retry do
      expect(results).to have_content(@london_mathematics_course.name_and_code)
      expect(results).to have_content(@romford_mathematics_course.name_and_code)
      expect(results).to have_content(@watford_mathematics_course.name_and_code)

      expect(results).to have_no_content(@london_primary_course.name_and_code)
      expect(results).to have_no_content(@romford_primary_course.name_and_code)
      expect(results).to have_no_content(@watford_primary_course.name_and_code)
    end
  end

  def then_i_see_mathematics_courses_in_15_miles_from_london_that_sponsors_visa
    with_retry do
      expect(results).to have_content(@london_mathematics_course.name_and_code)

      expect(results).to have_no_content(@romford_mathematics_course.name_and_code)
      expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
      expect(results).to have_no_content(@london_primary_course.name_and_code)
      expect(results).to have_no_content(@romford_primary_course.name_and_code)
      expect(results).to have_no_content(@watford_primary_course.name_and_code)
    end
  end

  def when_i_search_for_a_provider
    page.find(
      "summary.govuk-details__summary",
      text: "Search by training provider",
    ).click

    fill_in "Enter a provider name", with: "uni"
  end

  def and_i_choose_the_first_provider_suggestion
    page.find_by_id("provider-code-field__option--0").click
  end

  def then_i_see_only_courses_from_that_provider
    with_retry do
      expect(results).to have_content("First university")

      providers = Provider.where.not(provider_name: "First university")

      providers.each do |provider|
        expect(results).to have_no_content(provider.provider_name)
      end
    end
  end

  def and_the_provider_field_is_visible
    expect(page).to have_css("details.govuk-details[open]")
  end

  def when_i_search_courses_in_london_using_old_parameters
    stub_london_location_search

    visit find_results_path(lq: "London, UK")
  end

  def and_london_is_displayed_in_text_field
    expect(
      page.find_field("City, town or postcode").value,
    ).to eq("London, UK")
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
