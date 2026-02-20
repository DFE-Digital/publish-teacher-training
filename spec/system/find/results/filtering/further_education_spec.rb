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

  def given_there_are_courses_containing_all_levels
    create(:course, :with_full_time_sites, :primary, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :secondary, name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, :further_education, name: "Further education", course_code: "K594")
  end

  def and_i_filter_by_further_education_courses
    page.find("h3", text: "Filter by\nFurther education\n(ages 16 and over)").click
    check "Further education courses", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_only_further_education__courses
    expect(results).to have_content("Further education (K594)")
    expect(results).to have_no_content("Biology (S872)")
    expect(results).to have_no_content("Chemistry (K592)")
  end

  def and_the_further_education_filter_is_checked
    expect(page).to have_checked_field("Further education courses", visible: :all)
  end
end
