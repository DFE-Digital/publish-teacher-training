# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when filtering by applications open", :js, service: :find do
  include FilteringHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_open_and_closed_courses
  end

  scenario "applications open is checked by default from search entry" do
    when_i_visit_the_find_results_page_from_search_entry
    then_i_see_only_open_courses
    and_the_applications_open_filter_is_checked
    and_i_see_the_applications_open_filter_count
    and_i_see_the_applications_open_active_filter_chip
  end

  scenario "unchecking applications open shows closed courses with status tag" do
    when_i_visit_the_find_results_page_from_search_entry
    and_i_uncheck_applications_open
    then_i_see_open_and_closed_courses
    and_i_see_the_not_accepting_applications_tag_for_the_closed_course
  end

  def given_there_are_open_and_closed_courses
    create(:course, :open, :with_full_time_sites, name: "Biology", course_code: "S872")
    create(:course, :closed, :with_full_time_sites, name: "Chemistry", course_code: "K592")
  end

  def when_i_visit_the_find_results_page_from_search_entry
    visit find_results_path(applications_open: true)
  end

  def and_i_uncheck_applications_open
    page.find("h3", text: "Filter by\nApplications open").click
    uncheck "Only show courses open for applications", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_only_open_courses
    with_retry do
      expect(results).to have_content("Biology (S872)")
      expect(results).to have_no_content("Chemistry (K592)")
    end
  end

  def then_i_see_open_and_closed_courses
    with_retry do
      expect(results).to have_content("Biology (S872)")
      expect(results).to have_content("Chemistry (K592)")
    end
  end

  def and_the_applications_open_filter_is_checked
    expect(page).to have_checked_field("Only show courses open for applications", visible: :all)
  end

  def and_i_see_the_applications_open_filter_count
    within("details", text: "Applications open") do
      expect(page).to have_content("1 selected")
    end
  end

  def and_i_see_the_applications_open_active_filter_chip
    expect(page).to have_css(".app-active-filters", text: "Courses open for applications")
  end

  def and_i_see_the_not_accepting_applications_tag_for_the_closed_course
    within(".app-search-results") do
      expect(page).to have_css(".app-saved-course__status-tag", text: "Not accepting applications")
    end
  end
end
