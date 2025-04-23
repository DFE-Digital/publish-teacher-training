# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when searching for engineers teach physics", :js, service: :find do
  include FilteringHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_courses_with_secondary_subjects
    and_there_are_courses_with_primary_subjects
    when_i_visit_the_find_results_page
  end

  scenario "when searching for physics" do
    then_engineers_teach_physics_filter_is_not_visible

    when_i_check_physics
    and_i_apply_the_filters
    then_engineers_teach_physics_filter_is_visible
    and_physics_and_engineers_teach_physics_courses_are_visible
    and_i_see_that_two_courses_are_found

    when_i_check_engineers_teach_physics_only_filter
    and_i_apply_the_filters
    then_engineers_teach_physics_filter_is_visible
    and_only_engineers_teach_physics_courses_are_visible
    and_i_see_that_there_is_one_course_found

    when_i_uncheck_physics
    and_i_apply_the_filters
    then_engineers_teach_physics_filter_is_not_visible
    and_i_see_that_ten_courses_are_found
  end

  scenario "when searching for physics on subjects field" do
    then_engineers_teach_physics_filter_is_not_visible

    when_i_search_for_physics_in_subjects_autocomplete
    and_i_select_the_first_subject_suggestion
    and_i_click_search
    then_engineers_teach_physics_filter_is_visible
    and_physics_and_engineers_teach_physics_courses_are_visible
    and_i_see_that_two_courses_are_found

    and_i_remove_the_subject
    and_i_click_search
    then_engineers_teach_physics_filter_is_not_visible
  end

  def when_i_search_for_physics_in_subjects_autocomplete
    fill_in "Subject", with: "Physics"
  end

  def and_i_remove_the_subject
    fill_in "Subject", with: ""
    page.find('input[name="subject_name"]').send_keys(:backspace)
  end

  def and_i_select_the_first_subject_suggestion
    page.find('input[name="subject_name"]').native.send_keys(:return)
  end

  def then_engineers_teach_physics_filter_is_not_visible
    expect(page).to have_no_content("Only show Engineers teach physics courses")
  end

  def when_i_check_physics
    check "Physics", visible: :all
  end

  def when_i_uncheck_physics
    uncheck "Physics", visible: :all
  end

  def and_physics_and_engineers_teach_physics_courses_are_visible
    expect(page).to have_content(@physics_course.name_and_code)
    expect(page).to have_content(@engineers_teach_physics_course.name_and_code)
    expect(page).to have_no_content(@biology_course.name_and_code)
    expect(page).to have_no_content(@chemistry_course.name_and_code)
    expect(page).to have_no_content(@computing_course.name_and_code)
    expect(page).to have_no_content(@mathematics_course.name_and_code)
  end

  def then_engineers_teach_physics_filter_is_visible
    expect(page).to have_content("Only show Engineers teach physics courses")
  end

  def when_i_check_engineers_teach_physics_only_filter
    check "Only show Engineers teach physics courses", visible: :all
  end

  def and_only_engineers_teach_physics_courses_are_visible
    expect(page).to have_content(@engineers_teach_physics_course.name_and_code)
    expect(page).to have_no_content(@physics_course.name_and_code)
    expect(page).to have_no_content(@biology_course.name_and_code)
    expect(page).to have_no_content(@chemistry_course.name_and_code)
    expect(page).to have_no_content(@computing_course.name_and_code)
    expect(page).to have_no_content(@mathematics_course.name_and_code)
  end

  def and_i_see_that_ten_courses_are_found
    expect(page).to have_content("10 courses found")
    expect(page).to have_title("10 courses found")
  end
end
