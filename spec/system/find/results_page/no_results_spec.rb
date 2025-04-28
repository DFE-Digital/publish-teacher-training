# frozen_string_literal: true

require "rails_helper"

RSpec.describe "No search results", :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    when_i_visit_the_results_page
  end

  scenario "when searching for courses in Northern Ireland" do
    when_i_search_courses_in_northern_ireland
    then_i_see_northern_ireland_no_results_content
  end

  scenario "when searching for courses in England with no results" do
    when_i_search_courses_in_england
    then_i_see_no_results_content

    and_i_search_multiple_subjects
    then_i_see_no_results_for_subjects_content
  end

  scenario "when searching for teacher degree apprenticeship courses with no results" do
    given_courses_exist
    when_i_search_teacher_degree_apprenticeship_courses_in_england
    then_i_see_teacher_degree_apprenticeship_no_results_content
  end

  scenario "when there are no results for the given radius, a selection of wider search options are given" do
    given_courses_exist
    when_i_search_for_maths_in_london
    then_i_see_radius_quick_links
    then_i_click_on_radius_quick_link
  end

  def given_courses_exist
    romford = build(:location, :romford)
    bristol = build(:location, :bristol)

    create(
      :course,
      :primary,
      name: "Primary - London",
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: romford.latitude, longitude: romford.longitude))],
      subjects: [find_or_create(:primary_subject, :primary)],
    )

    create(
      :course,
      :secondary,
      name: "Mathematics - Bristol",
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: bristol.latitude, longitude: bristol.longitude))],
      subjects: [find_or_create(:secondary_subject, :mathematics)],
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

  def and_i_click_search
    click_link_or_button "Search"
  end

  def and_i_see_the_service_is_only_for_courses_in_england
    expect(page).to have_content("No courses found")
    expect(page).to have_content("This service is for courses in England")
  end

  def when_i_search_for_maths_in_london
    stub_autocomplete_request("London")

    fill_in "Subject", with: "Mathematics"
    fill_in "City, town or postcode", with: "London"
    and_i_set_the_radius_to_10_miles
    stub_geocode_request("London")
    and_i_click_search
  end

  def then_i_see_radius_quick_links
    expect(page).to have_content("No courses found")
    expect(page).to have_content("Try browsing for 'Mathematics' in a wider location search")
    expect(page).to have_content("200 miles (1 course)")
  end

  def then_i_click_on_radius_quick_link
    click_link "200 miles (1 course)"
    expect(page).to have_content("1 course found")
    expect(page).to have_content("Mathematics - Bristol")
  end

  def when_i_search_courses_in_england
    stub_autocomplete_request("London")

    fill_in "City, town or postcode", with: "London"
    stub_geocode_request("London")
    and_i_set_the_radius_to_10_miles
    and_i_click_search
  end

  def then_i_see_no_results_content
    expect(page).to have_content(
      "You can try another search, for example by changing subject, location or radius.",
    )
  end

  def and_i_search_multiple_subjects
    check "Primary", visible: :all
    check "Drama", visible: :all

    click_link_or_button "Apply filters", match: :first
  end

  def then_i_see_no_results_for_subjects_content
    expect(page).to have_content(
      "You can try another search, for example by changing subjects, location or radius.",
    )
  end

  def when_i_search_teacher_degree_apprenticeship_courses_in_england
    choose "No degree", visible: :all
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

  def when_i_set_the_radius_to_10_miles
    select "10 miles", from: "radius"
  end
  alias_method :and_i_set_the_radius_to_10_miles, :when_i_set_the_radius_to_10_miles

  def when_i_visit_the_results_page
    visit find_results_path
  end
end
