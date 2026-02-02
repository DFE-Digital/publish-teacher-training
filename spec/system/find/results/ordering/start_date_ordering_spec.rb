# frozen_string_literal: true

require "rails_helper"
require_relative "ordering_helper"

RSpec.describe "Search results ordering by start date", :js, service: :find do
  include OrderingHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "ordering by soonest start date" do
    given_there_are_courses_with_different_start_dates
    when_i_visit_the_find_results_page
    and_i_sort_by_soonest_start_date
    then_the_courses_are_ordered_by_start_date_ascending
  end

  scenario "secondary sort by course name when start dates are equal" do
    given_there_are_courses_with_same_start_date
    when_i_visit_the_find_results_page
    and_i_sort_by_soonest_start_date
    then_courses_are_sorted_by_name_within_same_start_date
  end

  scenario "start date is shown on course result when sorting by soonest start date" do
    given_there_are_courses_with_different_start_dates
    when_i_visit_the_find_results_page
    then_the_start_date_is_not_shown
    and_i_sort_by_soonest_start_date
    then_the_start_date_is_shown_on_each_course
  end

  def given_there_are_courses_with_different_start_dates
    provider = create(:provider, provider_name: "Test Provider")

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Late Start",
           course_code: "LAT1",
           start_date: 30.days.from_now)

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Early Start",
           course_code: "EAR1",
           start_date: 5.days.from_now)

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Mid Start",
           course_code: "MID1",
           start_date: 15.days.from_now)
  end

  def given_there_are_courses_with_same_start_date
    provider = create(:provider, provider_name: "Test Provider")
    same_date = 10.days.from_now

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Zebra Course",
           course_code: "ZEB1",
           start_date: same_date)

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Alpha Course",
           course_code: "ALP1",
           start_date: same_date)
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def and_i_sort_by_soonest_start_date
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Soonest start date", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def then_the_courses_are_ordered_by_start_date_ascending
    expect(result_titles).to eq([
      "Test Provider Early Start (EAR1)",
      "Test Provider Mid Start (MID1)",
      "Test Provider Late Start (LAT1)",
    ])
  end

  def then_courses_are_sorted_by_name_within_same_start_date
    expect(result_titles).to eq([
      "Test Provider Alpha Course (ALP1)",
      "Test Provider Zebra Course (ZEB1)",
    ])
  end

  def then_the_start_date_is_not_shown
    within(".app-search-results") do
      expect(page).to have_no_content("Start date")
    end
  end

  def then_the_start_date_is_shown_on_each_course
    within(".app-search-results") do
      expect(page).to have_content("Start date", count: 3)
    end
  end
end
