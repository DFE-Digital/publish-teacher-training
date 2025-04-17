# frozen_string_literal: true

require "rails_helper"
require_relative "../results_helper"

RSpec.describe "Search results by subject and location", :js, service: :find do
  include FiltersFeatureSpecsHelper
  include ResultsHelper
  #  [["Primary - TR17 0HF", 0.0],
  # ["Primary - London", 252.23020587571304],
  # ["Primary - Penzance", 2.602787879248636],
  # ["Primary - Cornwall", 44.83454822350778],
  # ["Mathematics - TR17 0HF", 0.0],
  # ["Mathematics - Penzance", 2.602787879248636],
  # ["Mathematics - Cornwall", 44.83454822350778],
  # ["Mathematics - London", 252.23020587571304]]
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))

    given_courses_exist_in_various_locations
    when_i_visit_the_homepage
  end

  scenario "when I search from the homepage" do
    when_i_start_typing_an_invalid_location
    then_i_see_no_autocomplete_suggestions

    when_i_start_typing_postcode_location
    then_i_see_location_suggestions("Beacon Road, Marazion TR17 0HF, UK")
    and_the_location_suggestions_for_postcode_is_cached

    when_i_select_the_first_suggestion
    and_i_click_to_search_courses_in_postcode
    then_i_see_only_courses_within_selected_location_within_default_radius
    and_the_default_radius_for_postcode_is_selected
    and_the_postcode_location_search_for_coordinates_is_cached

    and_i_am_on_the_results_page_with_postcode_location_as_parameter
  end

  scenario "when I search all filters from the homepage" do
    when_i_search_for_math
    and_i_choose_the_first_subject_suggestion

    when_i_start_typing_postcode_location
    then_i_see_location_suggestions("Beacon Road, Marazion TR17 0HF, UK")

    when_i_select_the_first_suggestion
    and_i_check_visa_sponsorship_filter_in_the_homepage
    and_i_click_to_search_courses_in_postcode

    then_i_see_mathematics_courses_in_3_miles_from_postcode_that_sponsors_visa
    and_i_am_on_the_results_page_with_mathematics_subject_and_postcode_location_and_sponsor_visa_as_parameter
  end

  def when_i_start_typing_postcode_location
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:uk&input=TR17&key=replace_me&language=en&types=geocode",
    ).with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Connection" => "keep-alive",
        "Keep-Alive" => "30",
        "User-Agent" => "Faraday v#{Faraday::VERSION}",
      },
    ).to_return(status: 200, body: file_fixture("google_old_places_api_client/autocomplete/postcode.json"), headers: { "Content-Type" => "application/json" })

    fill_in "City, town or postcode", with: "TR17"
  end

  def and_the_location_suggestions_for_postcode_is_cached
    expect(Rails.cache.read("geolocation:suggestions:tr17")).to eq(
      [
        {
          name: "Beacon Road, Marazion TR17 0HF, UK",
          place_id: "ChIJu0TvYk7bakgR8HSit5vKcd8",
          types: %w[geocode postal_code],
        },
      ],
    )
  end

  def stub_postcode_location_search
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/geocode/json?address=Beacon%20Road,%20Marazion%20TR17%200HF,%20UK&components=country:UK&key=replace_me&language=en",
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
        body: file_fixture("google_old_places_api_client/geocode/postcode.json").read,
        headers: { "Content-Type" => "application/json" },
      )
  end

  def and_i_click_to_search_courses_in_postcode
    stub_postcode_location_search

    and_i_click_search
  end

  def and_the_postcode_location_search_for_coordinates_is_cached
    expect(Rails.cache.read("geolocation:query:beacon-road-marazion-tr17-0hf-uk")).to eq(
      {
        formatted_address: "Beacon Rd, Marazion TR17 0HF, UK",
        latitude: 50.1239982,
        longitude: -5.4740404,
        country: "England",
        types: %w[route],
      },
    )
  end

  def then_i_see_only_courses_within_selected_location_within_default_radius
    expect(results).to have_content(@postcode_primary_course.name_and_code)
    expect(results).to have_content(@postcode_mathematics_course.name_and_code)
    expect(results).to have_content(@penzance_primary_course.name_and_code)
    expect(results).to have_content(@penzance_mathematics_course.name_and_code)

    expect(results).to have_no_content(@cornwall_primary_course.name_and_code)
    expect(results).to have_no_content(@cornwall_mathematics_course.name_and_code)
  end

  def and_the_default_radius_for_postcode_is_selected
    expect(page).to have_select("Search radius", selected: "10 miles")
  end

  def and_i_am_on_the_results_page_with_postcode_location_as_parameter
    and_i_am_on_the_results_page

    expect(search_params).to eq(applications_open: "true", subject_name: "", subject_code: "", location: "Beacon Road, Marazion TR17 0HF, UK", provider_name: "", provider_code: "")
  end

  def and_i_am_on_the_results_page_with_mathematics_subject_and_postcode_location_and_sponsor_visa_as_parameter
    and_i_am_on_the_results_page

    expect(search_params).to eq(
      applications_open: "true",
      subject_name: "Mathematics",
      subject_code: "G1",
      location: "Beacon Road, Marazion TR17 0HF, UK",
      can_sponsor_visa: "true",
      provider_name: "",
      provider_code: "",
    )
  end

  def then_i_see_mathematics_courses_in_3_miles_from_postcode_that_sponsors_visa
    expect(results).to have_content(@postcode_mathematics_course.name_and_code)
    expect(results).to have_content("3 miles from Beacon Rd, Marazion TR17 0HF, UK")

    expect(results).to have_no_content(@penzance_primary_course.name_and_code)
  end
end
