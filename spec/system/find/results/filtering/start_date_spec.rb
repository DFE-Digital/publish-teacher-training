# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when filtering by start date", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_courses_exist_with_varied_start_dates
  end

  scenario "the options are grouped under the cycle year and the year after" do
    when_i_visit_the_find_results_page
    and_i_open_the_start_date_filter
    then_i_see_the_cycle_year_options
    and_i_see_the_next_year_options
  end

  scenario "filtering by a bucket in the cycle year" do
    when_i_visit_the_find_results_page
    and_i_open_the_start_date_filter
    and_i_check "April to June", in_year: current_recruitment_cycle_year
    and_i_apply_the_filters
    then_i_see_only(@may_course)
    and_i_see_the_active_filter("Start date: April to June #{current_recruitment_cycle_year}")
    and_the_start_date_is_not_shown_on_the_results
  end

  scenario "filtering by the same months in the following year" do
    when_i_visit_the_find_results_page
    and_i_open_the_start_date_filter
    and_i_check "January to March", in_year: next_recruitment_cycle_year
    and_i_apply_the_filters
    then_i_see_only(@next_year_january_course)
    and_i_see_the_active_filter("Start date: January to March #{next_recruitment_cycle_year}")
  end

  scenario "filtering by September" do
    when_i_visit_the_find_results_page
    and_i_open_the_start_date_filter
    and_i_check "September only", in_year: current_recruitment_cycle_year
    and_i_apply_the_filters
    then_i_see_only(@beginning_of_september_course, @middle_of_september_course, @end_of_september_course)
    and_i_see_the_active_filter("Start date: September #{current_recruitment_cycle_year} only")
  end

  scenario "filtering by several buckets across both years" do
    when_i_visit_the_find_results_page
    and_i_open_the_start_date_filter
    and_i_check "July and August", in_year: current_recruitment_cycle_year
    and_i_check "July only", in_year: next_recruitment_cycle_year
    and_i_apply_the_filters
    then_i_see_only(@august_course, @next_year_july_course)
  end

  scenario "following a link with an option the filter used to offer" do
    when_i_visit_the_find_results_page_with_start_date("oct_to_jul")
    then_i_see_only(@october_course, @next_year_january_course, @next_year_july_course)
    and_i_see_the_active_filter("Start date: October to December #{current_recruitment_cycle_year}")
    when_i_open_the_start_date_filter
    then_the_options_it_replaced_are_checked
  end

  def given_courses_exist_with_varied_start_dates
    @january_course = create_course("Art and design", current_recruitment_cycle_year, 1, 1)
    @may_course = create_course("Biology", current_recruitment_cycle_year, 5, 1)
    @august_course = create_course("Chemistry", current_recruitment_cycle_year, 8, 31)
    @beginning_of_september_course = create_course("Computing", current_recruitment_cycle_year, 9, 1)
    @middle_of_september_course = create_course("English", current_recruitment_cycle_year, 9, 15)
    @end_of_september_course = create_course("Primary with english", current_recruitment_cycle_year, 9, 30)
    @october_course = create_course("Spanish", current_recruitment_cycle_year, 10, 1)
    @next_year_january_course = create_course("Mathematics", next_recruitment_cycle_year, 1, 15)
    @next_year_july_course = create_course("Physics", next_recruitment_cycle_year, 7, 1)
  end

  def create_course(name, year, month, day)
    create(:course, :with_full_time_sites, name:, start_date: Time.zone.local(year, month, day))
  end

  def all_courses
    [
      @january_course,
      @may_course,
      @august_course,
      @beginning_of_september_course,
      @middle_of_september_course,
      @end_of_september_course,
      @october_course,
      @next_year_january_course,
      @next_year_july_course,
    ]
  end

  def when_i_visit_the_find_results_page_with_start_date(start_date)
    visit find_results_path(start_date: [start_date])
  end

  def and_i_open_the_start_date_filter
    page.find("h3", text: "Filter by\nStart date").click
  end
  alias_method :when_i_open_the_start_date_filter, :and_i_open_the_start_date_filter

  def and_i_check(label, in_year:)
    within_fieldset(in_year.to_s) { check label, visible: :all }
  end

  def then_i_see_the_cycle_year_options
    within_fieldset(current_recruitment_cycle_year.to_s) do
      expect(page).to have_field("January to March", visible: :all)
      expect(page).to have_field("April to June", visible: :all)
      expect(page).to have_field("July and August", visible: :all)
      expect(page).to have_field("September only", visible: :all)
      expect(page).to have_field("October to December", visible: :all)
    end
  end

  def and_i_see_the_next_year_options
    within_fieldset(next_recruitment_cycle_year.to_s) do
      expect(page).to have_field("January to March", visible: :all)
      expect(page).to have_field("April to June", visible: :all)
      expect(page).to have_field("July only", visible: :all)
      expect(page).to have_no_field("September only", visible: :all)
    end
  end

  def then_the_options_it_replaced_are_checked
    within_fieldset(current_recruitment_cycle_year.to_s) do
      expect(page).to have_checked_field("October to December", visible: :all)
      expect(page).to have_unchecked_field("September only", visible: :all)
    end
    within_fieldset(next_recruitment_cycle_year.to_s) do
      expect(page).to have_checked_field("January to March", visible: :all)
      expect(page).to have_checked_field("April to June", visible: :all)
      expect(page).to have_checked_field("July only", visible: :all)
    end
  end

  def then_i_see_only(*courses)
    with_retry do
      courses.each { |course| expect(results).to have_content(course.name) }
      (all_courses - courses).each { |course| expect(results).to have_no_content(course.name) }
    end
  end

  def and_the_start_date_is_not_shown_on_the_results
    expect(results).to have_no_content("Start date")
  end

  def and_i_see_the_active_filter(text)
    expect(page).to have_css(".app-active-filters", text:)
  end

  def next_recruitment_cycle_year
    current_recruitment_cycle_year + 1
  end
end
