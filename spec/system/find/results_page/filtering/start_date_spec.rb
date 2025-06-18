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

  def given_courses_exist_with_varied_start_dates
    @january_course = create(
      :course,
      :with_full_time_sites,
      name: "Art and design",
      start_date: DateTime.new(current_recruitment_cycle_year, 1, 1),
    )
    @august_course = create(
      :course,
      :with_full_time_sites,
      name: "Biology",
      start_date: DateTime.new(current_recruitment_cycle_year, 8, 1),
    )
    @beginning_of_september_course = create(
      :course,
      :with_full_time_sites,
      name: "Computing",
      start_date: DateTime.new(current_recruitment_cycle_year, 9, 1),
    )
    @middle_of_september_course = create(
      :course,
      :with_full_time_sites,
      name: "English",
      start_date: DateTime.new(current_recruitment_cycle_year, 9, 15),
    )
    @end_of_september_course = create(
      :course,
      :with_full_time_sites,
      name: "Primary with english",
      start_date: DateTime.new(current_recruitment_cycle_year, 9, 30),
    )
    @october_course = create(
      :course,
      :with_full_time_sites,
      name: "Spanish",
      start_date: DateTime.new(current_recruitment_cycle_year, 10, 1),
    )
  end

  def then_i_see_only_courses_starting_in_september
    with_retry do
      expect(results).to have_content(@beginning_of_september_course.name)
      expect(results).to have_content(@middle_of_september_course.name)
      expect(results).to have_content(@end_of_september_course.name)

      expect(results).to have_no_content(@january_course.name)
      expect(results).to have_no_content(@august_course.name)
      expect(results).to have_no_content(@october_course.name)
    end
  end

  def then_i_see_only_courses_not_starting_in_september
    with_retry do
      expect(results).to have_content(@january_course.name)
      expect(results).to have_content(@august_course.name)
      expect(results).to have_content(@october_course.name)

      expect(results).to have_no_content(@beginning_of_september_course.name)
      expect(results).to have_no_content(@middle_of_september_course.name)
      expect(results).to have_no_content(@end_of_september_course.name)
    end
  end

  def when_i_filter_by_all_start_date_options
    when_i_filter_by_september_start_date
    when_i_filter_by_non_september_start_dates
  end

  def then_i_see_all_courses_regardless_of_start_date
    with_retry do
      expect(results).to have_content(@january_course.name)
      expect(results).to have_content(@august_course.name)
      expect(results).to have_content(@october_course.name)
      expect(results).to have_content(@beginning_of_september_course.name)
      expect(results).to have_content(@middle_of_september_course.name)
      expect(results).to have_content(@end_of_september_course.name)
    end
  end

  def and_i_see_that_six_courses_are_found
    expect(page).to have_content("6 courses found")
    expect(page).to have_title("6 courses found")
  end

  def when_i_filter_by_non_september_start_dates
    check "All other dates", visible: :all
  end

  def when_i_filter_by_september_start_date
    check "September #{current_recruitment_cycle_year}", visible: :all
  end
end
