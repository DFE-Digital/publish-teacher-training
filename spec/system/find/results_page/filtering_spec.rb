# frozen_string_literal: true

require "rails_helper"
require_relative "./filtering_helper"

RSpec.describe "Search Results", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "when I filter by visa sponsorship" do
    given_there_are_courses_that_sponsor_visa
    and_there_are_courses_that_do_not_sponsor_visa
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_that_sponsor_visa
    then_i_see_only_courses_that_sponsor_visa
    and_the_visa_sponsorship_filter_is_checked
    and_i_see_that_three_courses_are_found
  end

  scenario "when I filter by study type" do
    given_there_are_courses_containing_all_study_types
    when_i_visit_the_find_results_page
    and_i_filter_only_by_part_time_courses
    then_i_see_only_part_time_courses
    and_the_part_time_filter_is_checked
    when_i_filter_only_by_full_time_courses
    then_i_see_only_full_time_courses
    and_the_full_time_filter_is_checked
    when_i_filter_by_part_time_and_full_time_courses
    then_i_see_all_courses_containing_all_study_types
    and_the_part_time_filter_is_checked
    and_the_full_time_filter_is_checked
  end

  scenario "when I filter by QTS-only courses" do
    given_there_are_courses_containing_all_qualifications
    when_i_visit_the_find_results_page
    and_i_filter_by_qts_only_courses
    then_i_see_only_qts_only_courses
    and_the_qts_only_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "when I filter by QTS with PGCE" do
    given_there_are_courses_containing_all_qualifications
    when_i_visit_the_find_results_page
    and_i_filter_by_qts_with_pgce_or_pgde_courses
    then_i_see_only_qts_with_pgce_or_pgde_courses
    and_the_qts_with_pgce_or_pgde_filter_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "when I filter by applications open" do
    given_there_are_courses_open_for_applications
    and_there_are_courses_that_are_closed_for_applications
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_open_for_applications
    then_i_see_only_courses_that_are_open_for_applications
    and_the_open_for_application_filter_is_checked
  end

  scenario "when I filter by special educational needs" do
    given_there_are_courses_with_special_education_needs
    and_there_are_courses_that_with_no_special_education_needs
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_with_special_education_needs
    then_i_see_only_courses_with_special_education_needs
    and_the_special_education_needs_filter_is_checked
  end
end
