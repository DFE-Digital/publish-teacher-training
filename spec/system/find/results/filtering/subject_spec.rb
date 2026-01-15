# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when I filter by subject", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_courses_with_secondary_subjects
    and_there_are_courses_with_primary_subjects
    when_i_visit_the_find_results_page
  end

  scenario "filter by specific primary subjects" do
    when_i_filter_by_primary
    then_i_see_only_primary_specific_courses
    and_the_primary_option_is_checked
    and_i_see_that_there_is_one_primary_course_found

    when_i_filter_by_primary_with_science_too
    then_i_see_primary_and_primary_with_science_courses
    and_the_primary_option_is_checked
    and_the_primary_with_science_option_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "filter by specific secondary subjects" do
    when_i_filter_by_mathematics
    then_i_see_only_mathematics_courses
    and_the_mathematics_secondary_option_is_checked
    and_i_see_that_there_is_one_mathematics_course_found
  end

  scenario "filter by many secondary subjects" do
    and_i_filter_by_mathematics
    and_i_filter_by_chemistry
    then_i_see_mathematics_and_chemistry_courses
    and_the_mathematics_secondary_option_is_checked
    and_the_chemistry_secondary_option_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "passing subjects on the parameters" do
    when_i_visit_the_find_results_page_passing_mathematics_in_the_params
    then_i_see_only_mathematics_courses
    and_the_mathematics_secondary_option_is_checked
    and_i_see_that_there_is_one_mathematics_course_found
  end

  def when_i_visit_the_find_results_page_passing_mathematics_in_the_params
    visit(find_results_path(subjects: %w[G1]))
  end

  def when_i_filter_by_primary
    page.find("h3", text: "Filter by\nPrimary\n(ages 3 to 11)").click
    check "Primary", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_primary_with_science_too
    page.find("h3", text: "Filter by\nPrimary\n(ages 3 to 11)").click
    check "Primary with science", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_mathematics
    page.find("h3", text: "Filter by\nSecondary\n(ages 11 to 18)").click
    check "Mathematics", visible: :all
    and_i_apply_the_filters
  end
  alias_method :and_i_filter_by_mathematics, :when_i_filter_by_mathematics

  def and_i_filter_by_chemistry
    page.find("h3", text: "Filter by\nSecondary\n(ages 11 to 18)").click
    check "Chemistry", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_only_primary_specific_courses
    with_retry do
      expect(results).to have_content("Primary (S872)")
      expect(results).to have_no_content("Primary with english")
      expect(results).to have_no_content("Primary with mathematics")
      expect(results).to have_no_content("Primary with science")
    end
  end

  def then_i_see_primary_and_primary_with_science_courses
    with_retry do
      expect(results).to have_content("Primary (S872)")
      expect(results).to have_content("Primary with science")
      expect(results).to have_no_content("Primary with english")
      expect(results).to have_no_content("Primary with mathematics")
    end
  end

  def and_the_primary_option_is_checked
    expect(page).to have_checked_field("Primary", visible: :all)
  end

  def and_the_primary_with_science_option_is_checked
    expect(page).to have_checked_field("Primary with science", visible: :all)
  end

  def then_i_see_mathematics_and_chemistry_courses
    with_retry do
      expect(results).to have_content("Mathematics")
      expect(results).to have_content("Chemistry")
      expect(results).to have_no_content("Biology")
      expect(results).to have_no_content("Computing")
    end
  end

  def and_the_mathematics_secondary_option_is_checked
    expect(page).to have_checked_field("Mathematics", visible: :all)
  end

  def and_the_chemistry_secondary_option_is_checked
    expect(page).to have_checked_field("Chemistry", visible: :all)
  end

  def and_i_see_that_there_is_one_primary_course_found
    expect(page.title).to eq("1 primary course - Find teacher training courses - GOV.UK")
    expect(page.find("h1").text).to eq("1 primary course")
  end

  def and_i_see_that_there_is_one_mathematics_course_found
    expect(page.title).to eq("1 mathematics course - Find teacher training courses - GOV.UK")
    expect(page.find("h1").text).to eq("1 mathematics course")
  end
end
