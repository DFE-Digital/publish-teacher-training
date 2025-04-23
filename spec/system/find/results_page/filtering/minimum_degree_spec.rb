# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when I filter by minimum degree", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_courses_with_various_degree_requirements
  end

  scenario "when 2:1 degree requirement shows courses requiring 2:1, 2:2, third-class, or pass degrees" do
    when_i_visit_the_find_results_page
    and_i_filter_courses_requiring_two_one_degree
    then_courses_with_two_one_or_lower_degree_requirement_are_visible
    and_the_two_one_filter_is_checked
    and_i_see_that_four_courses_are_found
  end

  scenario "when 2:2 degree requirement shows courses requiring 2:2, third-class, or pass degrees" do
    when_i_visit_the_find_results_page
    and_i_filter_courses_requiring_two_two_degree
    then_courses_with_two_two_or_lower_degree_requirement_are_visible
    and_the_two_two_filter_is_checked
    and_i_see_that_three_courses_are_found
  end

  scenario 'when "Third class" shows courses requiring third-class or an ordinary degree' do
    when_i_visit_the_find_results_page
    and_i_filter_courses_requiring_third_class_grade
    then_courses_with_third_class_or_lower_degree_requirement_are_visible
    and_the_third_class_filter_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario 'when "Pass" shows courses requiring an ordinary degree' do
    when_i_visit_the_find_results_page
    and_i_filter_courses_requiring_pass_grade
    then_only_courses_with_ordinary_degree_requirement_are_visible
    and_the_pass_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "filtering by 'No degree required' shows only undergraduate courses" do
    when_i_visit_the_find_results_page
    and_i_filter_courses_with_no_degree_requirement
    then_only_undergraduate_courses_are_visible
    and_the_no_degree_required_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "legacy parameters for 2:1 degree requirements shows relevant courses" do
    when_i_visit_the_find_results_page_using_old_two_one_parameter
    then_courses_with_two_one_or_lower_degree_requirement_are_visible
    and_the_two_one_filter_is_checked
    and_i_see_that_four_courses_are_found
  end

  scenario "legacy parameters for 2:2 degree requirements shows relevant courses" do
    when_i_visit_the_find_results_page_using_old_two_two_parameter
    then_courses_with_two_two_or_lower_degree_requirement_are_visible
    and_the_two_two_filter_is_checked
    and_i_see_that_three_courses_are_found
  end

  scenario "legacy parameters for third class degree requirements shows relevant courses" do
    when_i_visit_the_find_results_page_using_old_third_class_parameter
    then_courses_with_third_class_or_lower_degree_requirement_are_visible
    and_the_third_class_filter_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "legacy parameters for pass degree requirements shows relevant courses" do
    when_i_visit_the_find_results_page_using_old_pass_parameter
    then_only_courses_with_ordinary_degree_requirement_are_visible
    and_the_pass_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "legacy parameters for undergraduate courses shows relevant courses" do
    when_i_visit_the_find_results_page_using_old_undergraduate_courses_parameter
    then_only_undergraduate_courses_are_visible
    and_the_no_degree_required_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end
end
