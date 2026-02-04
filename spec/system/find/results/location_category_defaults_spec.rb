# frozen_string_literal: true

require "rails_helper"
require_relative "../results_helper"

RSpec.describe "Location category defaults", :js, service: :find do
  include FiltersFeatureSpecsHelper
  include ResultsHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
    FeatureFlag.activate(:find_filtering_and_sorting)

    given_courses_exist_in_various_locations
  end

  describe "Bug 1: Sort order resets when transitioning from non-location to location search" do
    scenario "searching by subject first, then adding a location resets sort order to distance" do
      when_i_visit_the_results_page

      # First search: subject only (no location) - default sort is course_name_ascending
      when_i_search_for_math
      and_i_choose_the_first_subject_suggestion
      and_i_click_search

      then_the_sort_order_is("course_name_ascending")

      # Second search: add a location - sort resets to distance
      when_i_start_typing_cornwall_location
      then_i_see_location_suggestions("Cornwall, UK")
      when_i_select_the_first_suggestion
      and_i_click_to_search_courses_in_cornwall

      then_the_sort_order_is("distance")
    end
  end

  describe "Bug 2: Radius resets when changing location category" do
    scenario "changing from London to Cornwall resets radius from 20 miles to 50 miles" do
      when_i_visit_the_results_page

      # First search: London - default radius is 20 miles
      when_i_start_typing_london_location
      then_i_see_location_suggestions("London, UK")
      when_i_select_the_first_suggestion
      and_i_click_to_search_courses_in_london

      then_the_radius_is("20")

      # Second search: Cornwall - radius resets to 50 miles (regional default)
      when_i_clear_and_type_cornwall_location
      then_i_see_location_suggestions("Cornwall, UK")
      when_i_select_the_first_suggestion
      and_i_click_to_search_courses_in_cornwall

      then_the_radius_is("50")
    end

    scenario "changing from Cornwall to London resets radius from 50 miles to 20 miles" do
      when_i_visit_the_results_page

      # First search: Cornwall - default radius is 50 miles
      when_i_start_typing_cornwall_location
      then_i_see_location_suggestions("Cornwall, UK")
      when_i_select_the_first_suggestion
      and_i_click_to_search_courses_in_cornwall

      then_the_radius_is("50")

      # Second search: London - radius resets to 20 miles
      when_i_clear_and_type_london_location
      then_i_see_location_suggestions("London, UK")
      when_i_select_the_first_suggestion
      and_i_click_to_search_courses_in_london

      then_the_radius_is("20")
    end

    scenario "staying in the same location category preserves user-selected radius" do
      when_i_visit_the_results_page

      # First search: Cornwall with custom radius
      when_i_start_typing_cornwall_location
      then_i_see_location_suggestions("Cornwall, UK")
      when_i_select_the_first_suggestion
      and_i_click_to_search_courses_in_cornwall

      when_i_change_radius_to("10")
      and_i_click_apply_filters

      then_the_radius_is("10")

      # Search again with same location category (still Cornwall/regional)
      # Radius remains 10 miles because category didn't change
      and_i_click_search

      then_the_radius_is("10")
    end
  end

  def then_the_sort_order_is(expected_order)
    with_retry do
      expect(page).to have_checked_field(sort_order_label(expected_order), visible: :all)
    end
  end

  def then_the_radius_is(expected_radius)
    with_retry do
      expect(page).to have_checked_field("#{expected_radius} miles", visible: :all)
    end
  end

  def when_i_change_radius_to(radius)
    page.find("h3", text: "Location search radius").click
    choose "#{radius} miles"
  end

  def when_i_clear_and_type_cornwall_location
    stub_autocomplete_cornwall
    fill_in "City, town or postcode", with: ""
    fill_in "City, town or postcode", with: "Corn"
  end

  def when_i_clear_and_type_london_location
    stub_autocomplete_london
    fill_in "City, town or postcode", with: ""
    fill_in "City, town or postcode", with: "Lon"
  end

  def sort_order_label(order)
    case order
    when "distance"
      "Distance"
    when "course_name_ascending"
      "Course name (a to z)"
    when "provider_name_ascending"
      "Training provider (a to z)"
    else
      order
    end
  end

  def with_retry(attempts: 3)
    attempts.times do |i|
      yield
      break
    rescue RSpec::Expectations::ExpectationNotMetError
      raise if i == attempts - 1

      sleep 0.5
    end
  end
end
