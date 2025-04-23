# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when I filter by further education only courses", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_courses_containing_all_levels
  end

  scenario "when I filter by further education only courses" do
    when_i_visit_the_find_results_page
    and_i_filter_by_further_education_courses
    then_i_see_only_further_education__courses
    and_the_further_education_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "when I filter by the old age group further education parameter" do
    when_i_visit_the_find_results_page_using_the_old_age_group_parameter
    then_i_see_only_further_education__courses
    and_the_further_education_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "when I filter by the old pgce pgde further education parameter" do
    when_i_visit_the_find_results_page_using_the_old_pgce_pgde_parameter
    then_i_see_only_further_education__courses
    and_the_further_education_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end
end
