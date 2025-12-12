# frozen_string_literal: true

require "rails_helper"
require_relative "./filtering_helper"

RSpec.describe "Filter count badges", :js, service: :find, travel: mid_cycle do
  include FilteringHelper

  before do
    given_there_is_a_course
  end

  describe "Sort by section" do
    scenario "does not show count badge when order is default" do
      when_i_visit_the_find_results_page
      then_the_sort_by_section_does_not_show_count_badge
    end

    scenario "does not show count badge when order param equals default and flag is false" do
      when_i_visit_the_find_results_page_with_default_order_and_flag_false
      then_the_sort_by_section_does_not_show_count_badge
    end

    scenario "shows count badge when order differs from default" do
      when_i_visit_the_find_results_page_with_non_default_order
      then_the_sort_by_section_shows_count_badge
    end

    scenario "shows count badge when order_explicitly_set is true even if value is default" do
      when_i_visit_the_find_results_page_with_default_order_and_flag_true
      then_the_sort_by_section_shows_count_badge
    end
  end

  describe "Search radius section" do
    before do
      stub_london_location_search
    end

    scenario "does not show count badge when radius is default" do
      when_i_visit_the_find_results_page_with_location
      then_the_search_radius_section_does_not_show_count_badge
    end

    scenario "shows count badge when radius differs from default" do
      when_i_visit_the_find_results_page_with_non_default_radius
      then_the_search_radius_section_shows_count_badge
    end

    scenario "shows count badge when radius_explicitly_set is true even if value is default" do
      when_i_visit_the_find_results_page_with_default_radius_and_flag_true
      then_the_search_radius_section_shows_count_badge
    end
  end

  describe "Degree grade section" do
    scenario "does not show count badge when minimum_degree_required is default" do
      when_i_visit_the_find_results_page
      then_the_degree_grade_section_does_not_show_count_badge
    end

    scenario "shows count badge when minimum_degree_required differs from default" do
      when_i_visit_the_find_results_page_with_non_default_degree
      then_the_degree_grade_section_shows_count_badge
    end

    scenario "shows count badge when minimum_degree_required_explicitly_set is true even if value is default" do
      when_i_visit_the_find_results_page_with_default_degree_and_flag_true
      then_the_degree_grade_section_shows_count_badge
    end
  end

private

  def given_there_is_a_course
    create(:course, :with_full_time_sites, name: "Biology", course_code: "S872")
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def when_i_visit_the_find_results_page_with_default_order_and_flag_false
    visit find_results_path(order: "course_name_ascending", order_explicitly_set: "false")
  end

  def when_i_visit_the_find_results_page_with_non_default_order
    visit find_results_path(order: "provider_name_ascending")
  end

  def when_i_visit_the_find_results_page_with_default_order_and_flag_true
    visit find_results_path(order: "course_name_ascending", order_explicitly_set: "true")
  end

  def when_i_visit_the_find_results_page_with_location
    # Default radius for London is 20
    visit find_results_path(location: "London, UK")
  end

  def when_i_visit_the_find_results_page_with_non_default_radius
    # Default for London is 20, so 50 is non-default
    visit find_results_path(location: "London, UK", radius: "50")
  end

  def when_i_visit_the_find_results_page_with_default_radius_and_flag_true
    visit find_results_path(location: "London, UK", radius: "20", radius_explicitly_set: "true")
  end

  def when_i_visit_the_find_results_page_with_non_default_degree
    visit find_results_path(minimum_degree_required: "two_one")
  end

  def when_i_visit_the_find_results_page_with_default_degree_and_flag_true
    visit find_results_path(minimum_degree_required: "show_all_courses", minimum_degree_required_explicitly_set: "true")
  end

  def then_the_sort_by_section_does_not_show_count_badge
    within_sort_by_section do
      expect(page).to have_no_content("1 selected")
    end
  end

  def then_the_sort_by_section_shows_count_badge
    within_sort_by_section do
      expect(page).to have_content("1 selected")
    end
  end

  def then_the_search_radius_section_does_not_show_count_badge
    within_search_radius_section do
      expect(page).to have_no_content("1 selected")
    end
  end

  def then_the_search_radius_section_shows_count_badge
    within_search_radius_section do
      expect(page).to have_content("1 selected")
    end
  end

  def then_the_degree_grade_section_does_not_show_count_badge
    within_degree_grade_section do
      expect(page).to have_no_content("1 selected")
    end
  end

  def then_the_degree_grade_section_shows_count_badge
    within_degree_grade_section do
      expect(page).to have_content("1 selected")
    end
  end

  def within_sort_by_section(&block)
    page.find("details", text: "Sort by").tap do |section|
      within(section, &block)
    end
  end

  def within_search_radius_section(&block)
    page.find("details", text: "Location search radius").tap do |section|
      within(section, &block)
    end
  end

  def within_degree_grade_section(&block)
    page.find("details", text: "Degree grade").tap do |section|
      within(section, &block)
    end
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
