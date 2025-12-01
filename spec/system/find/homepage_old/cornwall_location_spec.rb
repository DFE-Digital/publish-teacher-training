# frozen_string_literal: true

require "rails_helper"
require_relative "../results_helper"

RSpec.describe "Search results by subject and location", :js, service: :find do
  include FiltersFeatureSpecsHelper
  include ResultsHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))

    given_courses_exist_in_various_locations
    when_i_visit_the_homepage
  end

  scenario "when I search from the homepage" do
    when_i_start_typing_an_invalid_location
    then_i_see_no_autocomplete_suggestions

    when_i_start_typing_cornwall_location
    then_i_see_location_suggestions("Cornwall, UK")
    and_the_location_suggestions_for_cornwall_is_cached

    when_i_select_the_first_suggestion
    and_i_click_to_search_courses_in_cornwall
    then_i_see_only_courses_within_selected_location_within_default_radius
    and_the_default_radius_is_selected
    and_the_cornwall_location_search_for_coordinates_is_cached

    and_i_am_on_the_results_page_with_cornwall_location_as_parameter
  end

  scenario "when I search all filters from the homepage" do
    when_i_search_for_math
    and_i_choose_the_first_subject_suggestion

    when_i_start_typing_cornwall_location
    then_i_see_location_suggestions("Cornwall, UK")

    when_i_select_the_first_suggestion
    and_i_check_visa_sponsorship_filter_in_the_homepage
    and_i_click_to_search_courses_in_cornwall

    then_i_see_mathematics_courses_in_48_miles_from_penzance_that_sponsors_visa
    and_i_am_on_the_results_page_with_mathematics_subject_and_cornwall_location_and_sponsor_visa_as_parameter
  end
end
