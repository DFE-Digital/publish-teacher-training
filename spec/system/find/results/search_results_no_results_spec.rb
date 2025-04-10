# frozen_string_literal: true

require "rails_helper"

RSpec.describe "No search results", :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)

    given_courses_exist
    visit find_results_path
  end

  scenario "when searching for courses in Northern Ireland" do
    when_i_search_courses_in_northern_ireland
    then_i_see_northern_ireland_no_results_content
  end

  scenario "when searching for courses in Scotland" do
    when_i_search_courses_in_scotland
    then_i_see_scotland_no_results_content
  end

  scenario "when searching for courses in Wales" do
    when_i_search_courses_in_wales
    then_i_see_wales_no_results_content
  end

  scenario "when searching for courses in England with no results" do
    when_i_search_courses_in_england
    then_i_see_no_results_content

    and_i_search_multiple_subjects
    then_i_see_no_results_for_subjects_content
  end

  scenario "when searching for teacher degree apprenticeship courses with no results" do
    when_i_search_teacher_degree_apprenticeship_courses_in_england
    then_i_see_teacher_degree_apprenticeship_no_results_content
  end

  def given_courses_exist
    romford = build(:location, :romford)
    primary_subject = find_or_create(:primary_subject, :primary)

    create(
      :course,
      :primary,
      name: "Primary - London",
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: romford.latitude, longitude: romford.longitude))],
      subjects: [primary_subject],
    )
  end

  def when_i_search_courses_in_northern_ireland
    fill_in "City, town or postcode", with: "Belfast"
    stub_geocode_request("Belfast")
    stub_autocomplete_request("Belfast")
    and_i_click_search
  end

  def then_i_see_northern_ireland_no_results_content
    and_i_see_the_service_is_only_for_courses_in_england

    expect(page).to have_link(
      "Learn more about teacher training in Northern Ireland",
      href: find_track_click_path(url: "https://www.education-ni.gov.uk/articles/initial-teacher-education-courses-northern-ireland"),
    )
  end

  def when_i_search_courses_in_scotland
    fill_in "City, town or postcode", with: "Edinburgh"
    stub_geocode_request("Edinburgh")
    stub_autocomplete_request("Edinburgh")
    and_i_click_search
  end

  def then_i_see_scotland_no_results_content
    and_i_see_the_service_is_only_for_courses_in_england

    expect(page).to have_link(
      "Learn more about teacher training in Scotland",
      href: find_track_click_path(url: "https://teachinscotland.scot"),
    )
  end

  def when_i_search_courses_in_wales
    fill_in "City, town or postcode", with: "Cardiff"
    stub_geocode_request("Cardiff")
    stub_autocomplete_request("Cardiff")
    and_i_click_search
  end

  def then_i_see_wales_no_results_content
    and_i_see_the_service_is_only_for_courses_in_england

    expect(page).to have_link(
      "Learn more about teacher training in Wales",
      href: find_track_click_path(url: "https://educators.wales/teacher"),
    )
  end

  def and_i_click_search
    click_link_or_button "Search"
  end

  def and_i_see_the_service_is_only_for_courses_in_england
    expect(page).to have_content("No courses found")
    expect(page).to have_content("This service is for courses in England")
  end

  def when_i_search_courses_in_england
    stub_autocomplete_request("London")

    fill_in "City, town or postcode", with: "London"
    stub_geocode_request("London")
    and_i_click_search
  end

  def then_i_see_no_results_content
    expect(page).to have_content(
      "You can try another search, for example by changing subject or location.",
    )
  end

  def and_i_search_multiple_subjects
    check "Primary", visible: :all
    check "Drama", visible: :all

    click_link_or_button "Apply filters", match: :first
  end

  def then_i_see_no_results_for_subjects_content
    expect(page).to have_content(
      "You can try another search, for example by changing subjects or location.",
    )
  end

  def when_i_search_teacher_degree_apprenticeship_courses_in_england
    choose "No degree required", visible: :all
    and_i_click_search
  end

  def then_i_see_teacher_degree_apprenticeship_no_results_content
    expect(page).to have_content(
      "There are not many teacher degree apprenticeship (TDA) courses on the service at the moment. You can try again soon when there may be more courses, or get in touch with us at",
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
