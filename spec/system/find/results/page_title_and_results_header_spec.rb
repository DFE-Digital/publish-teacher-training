require "rails_helper"
require_relative "./filtering_helper"
require_relative "../results_helper"

RSpec.describe "Search results page title", :js, service: :find do
  include FilteringHelper
  include ResultsHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)

    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
    stub_autocomplete_london
    stub_london_location_search
    stub_autocomplete_cornwall
    stub_cornwall_location_search
    stub_british_museum_search

    given_courses_exist_in_various_locations
    and_there_are_courses_with_primary_subjects
    when_i_visit_the_results_page
  end

  scenario "when searching normally without filters" do
    then_i_see_page_title("12 courses found")
  end

  scenario "when searching by subject only" do
    when_i_search_for_mathematics
    and_i_choose_the_first_subject_suggestion
    and_i_click_search

    then_i_see_page_title("4 mathematics courses")
  end

  scenario "when filtering by subject only" do
    when_i_filter_for_mathematics
    and_i_click_search

    then_i_see_page_title("4 mathematics courses")
  end

  scenario "when filtering by many subjects" do
    when_i_filter_for_mathematics
    and_i_filter_for_primary
    and_i_click_search

    then_i_see_page_title("9 courses found")
  end

  scenario "when searching by location only (simple location)" do
    when_i_search_for_london
    and_i_click_search

    then_i_see_page_title("6 courses in London")
  end

  scenario "when searching by location only (postcode - distance search)" do
    when_i_search_for_landmark
    and_i_click_search

    then_i_see_page_title("6 courses within 50 miles of Great Russell Street, London")
  end

  scenario "when searching by subject and location" do
    when_i_search_for_mathematics
    and_i_choose_the_first_subject_suggestion
    when_i_search_for_london
    and_i_click_search

    then_i_see_page_title("1 mathematics course in London")
  end

  scenario "when searching by subject and postcode (distance search)" do
    when_i_search_for_mathematics
    and_i_choose_the_first_subject_suggestion
    when_i_search_for_landmark
    and_i_click_search

    then_i_see_page_title("1 mathematics course within 50 miles of Great Russell Street, London")

    and_i_set_the_radius_to_100_miles
    and_i_click_search
    then_i_see_page_title("1 mathematics course within 100 miles of Great Russell Street, London")
  end

  scenario "when there are no results" do
    when_i_search_for_a_subject_with_no_courses
    and_i_choose_the_first_subject_suggestion
    when_i_search_for_remote_location
    and_i_click_search
    and_i_set_the_radius_to_10_miles
    and_i_click_search

    then_i_see_page_title("No courses found")
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def when_i_search_for_mathematics
    fill_in "Subject", with: "Mathematics"
  end

  def when_i_search_for_a_subject_with_no_courses
    fill_in "Subject", with: "Drama"
  end

  def and_i_choose_the_first_subject_suggestion
    page.find('input[name="subject_name"]').native.send_keys(:return)
  end

  def when_i_search_for_london
    fill_in "City, town or postcode", with: "London"
  end

  def when_i_filter_for_mathematics
    filtering("Secondary") do
      check "Mathematics"
    end
  end

  def and_i_filter_for_primary
    filtering("Primary") do
      check "Primary"
    end
  end

  def when_i_search_for_landmark
    fill_in "City, town or postcode", with: "British museum"
  end

  def when_i_search_for_remote_location
    fill_in "City, town or postcode", with: "Cornwall"
  end

  def and_i_click_search
    click_link_or_button "Search"
  end

  def and_i_set_the_radius_to_10_miles
    page.find("h3", text: "Location search radius").click
    choose "10 miles"
  end

  def and_i_set_the_radius_to_100_miles
    page.find("h3", text: "Location search radius").click
    choose "100 miles"
  end

  def then_i_see_page_title(expected_title)
    with_retry do
      expect(header).to eq(expected_title)
      expect(page).to have_title("#{expected_title} - Find teacher training courses - GOV.UK")
    end
  end

  def header
    page.find("h1").text
  end

  def stub_british_museum_search
    stub_autocomplete_request("British museum")
    stub_geocode_request("British museum")
  end
end
