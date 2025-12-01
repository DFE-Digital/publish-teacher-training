# # frozen_string_literal: true

require "rails_helper"

RSpec.describe "Searching in Wales", :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)

    given_courses_exist
    visit find_results_path
  end

  scenario "when searching for courses in Wales and none found" do
    when_i_enter_cardiff_as_the_location
    and_i_set_the_radius_to_10_miles
    when_i_search_courses_in_wales
    then_i_see_wales_no_results_content
  end

  scenario "when searching for courses in Wales and one found" do
    when_i_enter_cardiff_as_the_location
    and_i_set_the_radius_to_50_miles
    when_i_search_courses_in_wales
    then_i_do_not_see_wales_no_results_content
    and_i_see_a_course_in_bristol
  end

  def and_i_see_a_course_in_bristol
    expect(page).to have_content(@bristol_course.name_and_code)
    expect(page).to have_content("26 miles from Cardiff, UK")
  end

  def given_courses_exist
    bristol = build(:location, :bristol)

    @bristol_course = create(
      :course,
      :secondary,
      name: "Mathematics - Bristol",
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: bristol.latitude, longitude: bristol.longitude))],
      subjects: [find_or_create(:secondary_subject, :mathematics)],
    )
  end

  def when_i_enter_cardiff_as_the_location
    fill_in "City, town or postcode", with: "Cardiff"
    stub_geocode_request("Cardiff")
    stub_autocomplete_request("Cardiff")
  end

  def when_i_search_courses_in_wales
    click_link_or_button "Search"
  end

  def and_i_set_the_radius_to_50_miles
    select "50 miles", from: "radius"
  end

  def and_i_set_the_radius_to_10_miles
    select "10 miles", from: "radius"
  end

  def and_i_see_the_service_is_only_for_courses_in_england
    expect(page).to have_content("No courses found")
    expect(page).to have_content("This service is for courses in England")
  end

  def then_i_do_not_see_wales_no_results_content
    expect(page).to have_no_content("No courses found")
    expect(page).to have_no_content("This service is for courses in England")
    expect(page).to have_no_link(
      "Learn more about teacher training in Wales",
      href: find_track_click_path(url: "https://educators.wales/teacher"),
    )
  end

  def then_i_see_wales_no_results_content
    and_i_see_the_service_is_only_for_courses_in_england

    expect(page).to have_link(
      "Learn more about teacher training in Wales",
      href: find_track_click_path(url: "https://educators.wales/teacher"),
    )
  end

  def stub_autocomplete_request(location)
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:uk&input=#{location}&key=replace_me&language=en&types=geocode",
    ).with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Connection" => "keep-alive",
        "Keep-Alive" => "30",
        "User-Agent" => "Faraday v#{Faraday::VERSION}",
      },
    ).to_return(
      status: 200,
      body: file_fixture("google_old_places_api_client/autocomplete/#{location.downcase}.json"),
      headers: { "Content-Type" => "application/json" },
    )
  end

  def stub_geocode_request(location)
    location_stub = location.downcase.gsub(" ", "_")

    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(location)}&components=country:UK&key=replace_me&language=en",
    ).with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Connection" => "keep-alive",
        "Keep-Alive" => "30",
        "User-Agent" => "Faraday v#{Faraday::VERSION}",
      },
    ).to_return(
      status: 200,
      body: file_fixture("google_old_places_api_client/geocode/#{location_stub}.json").read,
      headers: { "Content-Type" => "application/json" },
    )
  end
end
