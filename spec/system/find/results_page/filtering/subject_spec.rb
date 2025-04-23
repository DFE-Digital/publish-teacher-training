# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when I filter by subject", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_courses_with_secondary_subjects
    and_there_are_courses_with_primary_subjects
    when_i_visit_the_find_results_page
  end

  scenario "filter by specific primary subjects" do
    when_i_filter_by_primary
    then_i_see_only_primary_specific_courses
    and_the_primary_option_is_checked
    and_i_see_that_there_is_one_course_found

    when_i_filter_by_primary_with_science_too
    then_i_see_primary_and_primary_with_science_courses
    and_the_primary_option_is_checked
    and_the_primary_with_science_option_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "filter by specific secondary subjects" do
    and_i_search_for_the_mathematics_option
    then_i_can_only_see_the_mathematics_option
    when_i_clear_my_search_for_secondary_options
    then_i_can_see_all_secondary_options
    when_i_filter_by_mathematics
    then_i_see_only_mathematics_courses
    and_the_mathematics_secondary_option_is_checked
    and_i_see_that_there_is_one_course_found

    when_i_search_for_specific_secondary_options
    then_i_can_only_see_options_that_i_searched

    when_i_clear_my_search_for_secondary_options
    then_i_can_see_all_secondary_options
  end

  scenario "filter by many secondary subjects" do
    and_i_filter_by_mathematics
    and_i_filter_by_chemistry
    then_i_see_mathematics_and_chemistry_courses
    and_the_mathematics_secondary_option_is_checked
    and_the_chemistry_secondary_option_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "passing subjects on the parameters" do
    when_i_visit_the_find_results_page_passing_mathematics_in_the_params
    then_i_see_only_mathematics_courses
    and_the_mathematics_secondary_option_is_checked
    and_i_see_that_there_is_one_course_found
  end
end
