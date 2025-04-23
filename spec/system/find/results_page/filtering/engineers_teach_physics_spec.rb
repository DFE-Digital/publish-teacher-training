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
end
