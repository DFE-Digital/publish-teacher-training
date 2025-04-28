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

  scenario "filtering by 'No degree' shows only undergraduate courses" do
    when_i_visit_the_find_results_page
    and_i_filter_courses_with_no_degree_requirement
    then_only_undergraduate_courses_are_visible
    and_the_no_degree_required_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "filtering by 'Show all courses' shows all courses" do
    when_i_visit_the_find_results_page
    and_i_filter_courses_with_show_all_courses_requirement
    then_all_courses_are_visible
    and_i_see_that_five_courses_are_found
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

  def given_there_are_courses_with_various_degree_requirements
    create(:course, :published_postgraduate, degree_grade: "two_one", name: "Biology", course_code: "S872")
    create(:course, :published_postgraduate, degree_grade: "two_two", name: "Chemistry", course_code: "K592")
    create(:course, :published_postgraduate, degree_grade: "third_class", name: "Computing", course_code: "L364")
    create(:course, :published_postgraduate, degree_grade: "not_required", name: "Dance", course_code: "C115")
    create(:course, :published_teacher_degree_apprenticeship, degree_grade: "not_required", name: "Mathematics", course_code: "4RTU")
  end

  def when_i_visit_the_find_results_page_using_old_two_one_parameter
    visit(find_results_path(degree_required: "show_all_courses"))
  end

  def when_i_visit_the_find_results_page_using_old_two_two_parameter
    visit(find_results_path(degree_required: "two_two"))
  end

  def when_i_visit_the_find_results_page_using_old_third_class_parameter
    visit(find_results_path(degree_required: "third_class"))
  end

  def when_i_visit_the_find_results_page_using_old_pass_parameter
    visit(find_results_path(degree_required: "not_required"))
  end

  def when_i_visit_the_find_results_page_using_old_undergraduate_courses_parameter
    visit(find_results_path(university_degree_status: false))
  end

  def and_i_filter_courses_requiring_two_two_degree
    choose "2:2", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_requiring_pass_grade
    choose "Pass", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_with_no_degree_requirement
    choose "No degree", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_with_show_all_courses_requirement
    choose "Show all courses", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_requiring_two_one_degree
    choose "2:1 or First", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_requiring_third_class_grade
    choose "Third", visible: :all
    and_i_apply_the_filters
  end

  def and_the_two_two_filter_is_checked
    expect(page).to have_checked_field("2:2", visible: :all)
  end

  def and_the_third_class_filter_is_checked
    expect(page).to have_checked_field("Third", visible: :all)
  end

  def and_the_pass_filter_is_checked
    expect(page).to have_checked_field("Pass", visible: :all)
  end

  def and_the_no_degree_required_filter_is_checked
    expect(page).to have_checked_field("No degree", visible: :all)
  end

  def and_the_two_one_filter_is_checked
    expect(page).to have_checked_field("2:1 or First", visible: :all)
  end

  def then_courses_with_two_one_or_lower_degree_requirement_are_visible
    expect(results).to have_content("Biology")
    expect(results).to have_content("Chemistry")
    expect(results).to have_content("Computing")
    expect(results).to have_content("Dance")
    expect(results).to have_no_content("Mathematics")
  end

  def then_courses_with_two_two_or_lower_degree_requirement_are_visible
    expect(results).to have_content("Chemistry")
    expect(results).to have_content("Computing")
    expect(results).to have_content("Dance")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Mathematics")
  end

  def then_courses_with_third_class_or_lower_degree_requirement_are_visible
    expect(results).to have_content("Computing")
    expect(results).to have_content("Dance")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Chemistry")
    expect(results).to have_no_content("Mathematics")
  end

  def then_only_courses_with_ordinary_degree_requirement_are_visible
    expect(results).to have_content("Dance")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Chemistry")
    expect(results).to have_no_content("Computing")
    expect(results).to have_no_content("Mathematics")
  end

  def then_only_undergraduate_courses_are_visible
    expect(results).to have_content("Mathematics")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Dance")
    expect(results).to have_no_content("Chemistry")
    expect(results).to have_no_content("Computing")
  end

  def then_all_courses_are_visible
    expect(results).to have_content("Biology")
    expect(results).to have_content("Chemistry")
    expect(results).to have_content("Computing")
    expect(results).to have_content("Dance")
    expect(results).to have_content("Mathematics")
  end

  def and_i_see_that_four_courses_are_found
    expect(page).to have_content("4 courses found")
    expect(page).to have_title("4 courses found")
  end

  def and_i_see_that_five_courses_are_found
    expect(page).to have_content("5 courses found")
    expect(page).to have_title("5 courses found")
  end
end
