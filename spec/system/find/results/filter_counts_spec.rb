# frozen_string_literal: true

require "rails_helper"
require_relative "./filtering_helper"

RSpec.describe "Filter counts on search results", :js, service: :find do
  include FilteringHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "when I filter by funding type, the count is shown" do
    given_there_are_courses
    when_i_visit_the_find_results_page
    and_i_filter_by_salaried_courses
    then_i_see_the_funding_filter_count
  end

  scenario "when I filter by study type, the count is shown" do
    given_there_are_courses
    when_i_visit_the_find_results_page
    and_i_filter_by_part_time_courses
    then_i_see_the_study_type_filter_count
  end

  scenario "when I filter by qualification, the count is shown" do
    given_there_are_courses
    when_i_visit_the_find_results_page
    and_i_filter_by_qts_only
    then_i_see_the_qualification_filter_count
  end

  scenario "when I filter by SEND, the count is shown" do
    given_there_are_send_courses
    when_i_visit_the_find_results_page
    and_i_filter_by_send
    then_i_see_the_send_filter_count
  end

  scenario "when I filter by visa sponsorship, the count is shown" do
    given_there_are_courses
    when_i_visit_the_find_results_page
    and_i_filter_by_visa_sponsorship
    then_i_see_the_visa_filter_count
  end

  scenario "when I filter by degree requirement, the count is shown" do
    given_there_are_courses
    when_i_visit_the_find_results_page
    and_i_filter_by_degree_requirement
    then_i_see_the_degree_filter_count
  end

  scenario "when I filter by primary subjects, the count is shown" do
    given_there_are_primary_courses
    when_i_visit_the_find_results_page
    and_i_filter_by_primary_subjects
    then_i_see_the_primary_subjects_filter_count
  end

  scenario "when I filter by secondary subjects, the count is shown" do
    given_there_are_secondary_courses
    when_i_visit_the_find_results_page
    and_i_filter_by_secondary_subjects
    then_i_see_the_secondary_subjects_filter_count
  end

  scenario "when I change the sort order, the count is shown" do
    given_there_are_courses
    when_i_visit_the_find_results_page
    and_i_change_the_sort_order
    then_i_see_the_ordering_filter_count
  end

  def given_there_are_courses
    create(:course, :with_full_time_sites, :salary, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :fee, name: "Chemistry", course_code: "K592")
  end

  def given_there_are_send_courses
    create(:course, :with_full_time_sites, :with_special_education_needs, name: "Biology SEND", course_code: "S872")
    create(:course, :with_full_time_sites, name: "Chemistry", course_code: "K592")
  end

  def given_there_are_primary_courses
    create(:course, :open, :with_full_time_sites, :primary, name: "Primary", course_code: "P001", subjects: [find_or_create(:primary_subject, :primary)])
    create(:course, :open, :with_full_time_sites, :primary, name: "Primary with English", course_code: "P002", subjects: [find_or_create(:primary_subject, :primary_with_english)])
  end

  def given_there_are_secondary_courses
    create(:course, :open, :with_full_time_sites, :secondary, name: "Biology", course_code: "S001", subjects: [find_or_create(:secondary_subject, :biology)])
    create(:course, :open, :with_full_time_sites, :secondary, name: "Chemistry", course_code: "S002", subjects: [find_or_create(:secondary_subject, :chemistry)])
  end

  def and_i_filter_by_salaried_courses
    page.find("h3", text: "Filter by\nFee or salary").click
    check "Salary", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_part_time_courses
    page.find("h3", text: "Filter by\nFull time or part time").click
    check "Part time (18 to 24 months)", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_qts_only
    page.find("h3", text: "Filter by\nQualification").click
    check "QTS only", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_send
    page.find("h3", text: "Filter by\nSpecial educational needs\n(SEND)").click
    check "Only show courses with a SEND specialism", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_visa_sponsorship
    page.find("h3", text: "Filter by\nVisa Sponsorship").click
    check "Only show courses with visa sponsorship", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_degree_requirement
    page.find("h3", text: "Filter by\nDegree grade").click
    choose "2:1 or First", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_primary_subjects
    page.find("h3", text: "Filter by\nPrimary\n(ages 3 to 11)").click
    check "Primary", visible: :all
    check "Primary with English", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_secondary_subjects
    page.find("h3", text: "Filter by\nSecondary\n(ages 11 to 18)").click
    check "Biology", visible: :all
    check "Chemistry", visible: :all
    and_i_apply_the_filters
  end

  def and_i_change_the_sort_order
    page.find("h3", text: "Sort by").click
    choose "Training provider (a to z)", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_the_funding_filter_count
    within("details", text: "Fee or salary") do
      expect(page).to have_content("1 selected")
    end
  end

  def then_i_see_the_study_type_filter_count
    within("details", text: "Full time or part time") do
      expect(page).to have_content("1 selected")
    end
  end

  def then_i_see_the_qualification_filter_count
    within("details", text: "Qualification") do
      expect(page).to have_content("1 selected")
    end
  end

  def then_i_see_the_send_filter_count
    within("details", text: "Special educational needs") do
      expect(page).to have_content("1 selected")
    end
  end

  def then_i_see_the_visa_filter_count
    within("details", text: "Visa Sponsorship") do
      expect(page).to have_content("1 selected")
    end
  end

  def then_i_see_the_degree_filter_count
    within("details", text: "Degree grade") do
      expect(page).to have_content("1 selected")
    end
  end

  def then_i_see_the_primary_subjects_filter_count
    within("details", text: "Primary") do
      expect(page).to have_content("2 selected")
    end
  end

  def then_i_see_the_secondary_subjects_filter_count
    within("details", text: "Secondary") do
      expect(page).to have_content("2 selected")
    end
  end

  def then_i_see_the_ordering_filter_count
    within("details", text: "Sort by") do
      expect(page).to have_content("1 selected")
    end
  end
end
