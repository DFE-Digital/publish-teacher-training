# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when I filter by funding type", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_courses_with_all_funding_types
  end

  scenario "when I filter by salaried" do
    when_i_visit_the_find_results_page
    and_i_filter_by_salaried_courses
    then_i_see_only_salaried_courses
    and_the_salary_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "when I filter by fee" do
    when_i_visit_the_find_results_page
    and_i_filter_by_fee_courses
    then_i_see_only_fee_courses
    and_the_fee_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "when I filter by fee and salaried" do
    when_i_visit_the_find_results_page
    and_i_filter_by_fee_courses
    and_i_filter_by_salaried_courses
    then_i_see_fee_and_salaried_courses
    and_the_fee_filter_is_checked
    and_the_salary_filter_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "when I use the old funding parameter" do
    when_i_visit_the_find_results_page_using_old_salary_parameter
    then_i_see_only_salaried_courses
    and_the_salary_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "when I filter by apprenticeship" do
    when_i_visit_the_find_results_page
    and_i_filter_by_apprenticeship_courses
    then_i_see_only_apprenticeship_courses
    and_the_apprenticeship_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  def given_there_are_courses_with_all_funding_types
    create(:course, :with_full_time_sites, :fee_type_based, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :with_salary, name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, :with_apprenticeship, name: "Computing", course_code: "L364")
  end

  def when_i_visit_the_find_results_page_using_old_salary_parameter
    visit(find_results_path(funding: "salary"))
  end

  def and_i_filter_by_salaried_courses
    check "Salary", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_fee_courses
    check "Fee - no salary", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_apprenticeship_courses
    check "Teaching apprenticeship - with salary", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_only_salaried_courses
    expect(results).to have_content("Chemistry (K592)")
    expect(results).to have_no_content("Biology (S872)")
    expect(results).to have_no_content("Computing (L364)")
  end

  def then_i_see_only_fee_courses
    expect(results).to have_content("Biology (S872)")
    expect(results).to have_no_content("Chemistry (K592)")
    expect(results).to have_no_content("Computing (L364)")
  end

  def then_i_see_fee_and_salaried_courses
    expect(results).to have_content("Biology (S872)")
    expect(results).to have_content("Chemistry (K592)")
    expect(results).to have_no_content("Computing (L364)")
  end

  def then_i_see_only_apprenticeship_courses
    expect(results).to have_content("Computing (L364)")
    expect(results).to have_no_content("Chemistry (K592)")
    expect(results).to have_no_content("Biology (S872)")
  end

  def and_the_fee_filter_is_checked
    expect(page).to have_checked_field("Fee - no salary", visible: :all)
  end

  def and_the_salary_filter_is_checked
    expect(page).to have_checked_field("Salary", visible: :all)
  end

  def and_the_apprenticeship_filter_is_checked
    expect(page).to have_checked_field("Teaching apprenticeship - with salary", visible: :all)
  end
end
