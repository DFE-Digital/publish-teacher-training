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

    and_i_click_to_search_courses_in_london
    and_i_set_the_radius_to_10_miles
    and_the_10_mile_radius_is_selected
    and_i_click_to_search_courses_in_london
    then_i_only_see_courses_within_a_10_mile_radius
    and_the_location_search_for_coordinates_is_cached
    and_the_result_headers_are_visible

    when_i_increase_the_radius_to_20_miles
    and_i_click_search
    then_i_see_courses_up_to_20_miles_distance
    and_the_20_miles_radius_is_selected

    when_i_click_first_result
    then_i_am_on_course_page
    and_i_can_see_the_distance_from_london
  end

  scenario "when I filter by location and subject" do
    when_i_start_typing_london_location
    then_i_see_location_suggestions("London, UK")

    when_i_select_the_first_suggestion
    and_i_click_to_search_courses_in_london
    then_i_see_courses_up_to_20_miles_distance

    and_select_primary_subject
    and_i_click_search
    then_i_see_only_courses_within_selected_location_and_primary_subject_within_a_20_mile_radius
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
  end

  scenario "when search results update after filter changes" do
    when_i_search_for_math
    and_i_choose_the_first_subject_suggestion
    and_i_click_search
    then_i_do_not_see_the_location_filter

    when_i_start_typing_london_location
    then_i_see_location_suggestions("London, UK")
    when_i_select_the_first_suggestion
    and_i_click_to_search_courses_in_london

    when_i_increase_the_radius_to_20_miles
    when_i_filter_by_courses_that_sponsor_visa
    and_i_click_apply_filters

    then_i_see_mathematics_courses_in_20_miles_from_london_that_sponsors_visa
  end

  def then_i_do_not_see_the_location_filter
    expect(page).to have_no_content("Location search radius")
  end

  scenario 'when searching "London, UK" using old location parameters' do
    when_i_search_courses_in_london_using_old_parameters
    then_i_see_courses_up_to_20_miles_distance
    and_the_location_search_for_coordinates_is_cached
    and_london_is_displayed_in_text_field
  end

  scenario "search by subject synonym" do
    given_mathematics_has_synonyms
    when_i_visit_the_results_page
    when_i_search_for_a_mathematics_synonym
    then_i_can_see_the_mathematics_option
    when_i_click_search
    then_i_see_only_mathematics_courses
  end

  def given_mathematics_has_synonyms
    mathematics_subject = Subject.find_by!(subject_name: "Mathematics")

    DataHub::Subjects::UpdateMatchSynonyms.new(
      subject: mathematics_subject,
      synonyms: %w[Maths math],
    ).call
  end

  def when_i_search_for_a_mathematics_synonym
    fill_in "Subject", with: "maths"
  end

  def when_i_click_search
    click_link_or_button "Search"
  end
  alias_method :and_i_click_search, :when_i_click_search

  def then_i_can_see_the_mathematics_option
    subject_suggestions = page.all("#subject-code-field__listbox li").map(&:text)

    expect(subject_suggestions).to include("Mathematics")
  end

  def when_i_filter_by_courses_that_sponsor_visa
    page.find("h3", text: "Filter by\nVisa sponsorship").click
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

  def then_i_see_no_autocomplete_suggestions
    expect(page).to have_css("#location-field__listbox", visible: :hidden)
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
    expect(page).to have_checked_field("10 miles", visible: :hidden)
  end

  def and_the_20_miles_radius_is_selected
    expect(page).to have_checked_field("20 miles", visible: :hidden)
  end

  def when_i_set_the_radius_to_10_miles
    page.find("h3", text: "Location search radius").click
    choose "10 miles"
  end
  alias_method :and_i_set_the_radius_to_10_miles, :when_i_set_the_radius_to_10_miles

  def when_i_increase_the_radius_to_20_miles
    page.find("h3", text: "Location search radius").click
    choose "20 miles"
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

  def then_i_see_only_courses_within_selected_location_and_primary_subject_within_a_20_mile_radius
    with_retry do
      expect(results).to have_content(@london_primary_course.name_and_code)
      expect(results).to have_no_content(@london_mathematics_course.name_and_code)
      expect(results).to have_content(@romford_primary_course.name_and_code)
      expect(results).to have_no_content(@romford_mathematics_course.name_and_code)
      expect(results).to have_content(@watford_primary_course.name_and_code)
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

  def then_i_see_mathematics_courses_in_20_miles_from_london_that_sponsors_visa
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
    page.find("h3", text: "Filter by\nTraining provider").click

    fill_in "Provider name", with: "uni"
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

  def when_i_search_courses_in_london_using_old_parameters
    stub_london_location_search

    visit find_results_path(lq: "London, UK")
  end

  def and_london_is_displayed_in_text_field
    expect(
      page.find_field("City, town or postcode").value,
    ).to eq("London")
  end

  def when_i_click_first_result
    results.first("a").click
  end

  def then_i_am_on_course_page
    expect(page).to have_current_path(%r{\A/course/[A-Z0-9]+/[A-Z0-9]+\z}, ignore_query: true)
  end

  def and_i_can_see_the_distance_from_london
    expect(page).to have_content("1 mile from London")
  end

  def and_the_result_headers_are_visible
    expect(page.title).to eq("2 courses in London - Find teacher training courses - GOV.UK")
    expect(page).to have_content("2 courses in London")
  end
end
