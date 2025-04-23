# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when filtering by start date", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_courses_exist_with_varied_start_dates
    when_i_visit_the_find_results_page
  end

  scenario "filtering by September start date" do
    when_i_filter_by_september_start_date
    and_i_apply_the_filters
    then_i_see_only_courses_starting_in_september
    and_i_see_that_three_courses_are_found
  end

  scenario "filtering by all other start dates" do
    when_i_filter_by_non_september_start_dates
    and_i_apply_the_filters
    then_i_see_only_courses_not_starting_in_september
    and_i_see_that_three_courses_are_found
  end

  scenario "filtering by all available start dates" do
    when_i_filter_by_all_start_date_options
    and_i_apply_the_filters
    then_i_see_all_courses_regardless_of_start_date
    and_i_see_that_six_courses_are_found
  end
end
