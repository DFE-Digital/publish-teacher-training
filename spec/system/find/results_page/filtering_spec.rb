# frozen_string_literal: true

require "rails_helper"
require_relative "./filtering_helper"

RSpec.describe "Search Results", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "when I filter by visa sponsorship" do
    given_there_are_courses_that_sponsor_visa
    and_there_are_courses_that_do_not_sponsor_visa
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_that_sponsor_visa
    then_i_see_only_courses_that_sponsor_visa
    and_the_visa_sponsorship_filter_is_checked
    and_i_see_that_three_courses_are_found
  end

  scenario "when I filter by study type" do
    given_there_are_courses_containing_all_study_types
    when_i_visit_the_find_results_page
    and_i_filter_only_by_part_time_courses
    then_i_see_only_part_time_courses
    and_the_part_time_filter_is_checked
    when_i_filter_only_by_full_time_courses
    then_i_see_only_full_time_courses
    and_the_full_time_filter_is_checked
    when_i_filter_by_part_time_and_full_time_courses
    then_i_see_all_courses_containing_all_study_types
    and_the_part_time_filter_is_checked
    and_the_full_time_filter_is_checked
  end

  scenario "when I filter by QTS-only courses" do
    given_there_are_courses_containing_all_qualifications
    when_i_visit_the_find_results_page
    and_i_filter_by_qts_only_courses
    then_i_see_only_qts_only_courses
    and_the_qts_only_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "when I filter by QTS with PGCE" do
    given_there_are_courses_containing_all_qualifications
    when_i_visit_the_find_results_page
    and_i_filter_by_qts_with_pgce_or_pgde_courses
    then_i_see_only_qts_with_pgce_or_pgde_courses
    and_the_qts_with_pgce_or_pgde_filter_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "when I filter by applications open" do
    given_there_are_courses_open_for_applications
    and_there_are_courses_that_are_closed_for_applications
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_open_for_applications
    then_i_see_only_courses_that_are_open_for_applications
    and_the_open_for_application_filter_is_checked
  end

  scenario "when I filter by special educational needs" do
    given_there_are_courses_with_special_education_needs
    and_there_are_courses_that_with_no_special_education_needs
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_with_special_education_needs
    then_i_see_only_courses_with_special_education_needs
    and_the_special_education_needs_filter_is_checked
  end

  scenario "when I filter by online interviews" do
    given_there_are_courses_offering_online_interviews
    and_there_are_courses_that_offer_in_person_only_interviews
    when_i_visit_the_find_results_page
    and_i_filter_by_online_interviews
    then_i_see_only_courses_with_online_interviews
    and_the_online_interviews_filter_is_checked
  end

  def given_there_are_courses_that_sponsor_visa
    create(:course, :with_full_time_sites, :can_sponsor_skilled_worker_visa, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :can_sponsor_student_visa, name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa, name: "Computing", course_code: "L364")
  end

  def given_there_are_courses_containing_all_study_types
    create(:course, :with_full_time_sites, study_mode: "full_time", name: "Biology", course_code: "S872")
    create(:course, :with_part_time_sites, study_mode: "part_time", name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_or_part_time_sites, study_mode: "full_time_or_part_time", name: "Computing", course_code: "L364")
  end

  def given_there_are_courses_containing_all_qualifications
    create(:course, :with_full_time_sites, qualification: "qts", name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, qualification: "pgce_with_qts", name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, qualification: "pgde_with_qts", name: "Computing", course_code: "L364")
    create(:course, :with_full_time_sites, qualification: "pgce", name: "Dance", course_code: "C115")
    create(:course, :with_full_time_sites, qualification: "pgde", name: "Physics", course_code: "3CXN")
    create(:course, :with_full_time_sites, qualification: "undergraduate_degree_with_qts", name: "Mathemathics", course_code: "4RTU")
  end

  def given_there_are_courses_open_for_applications
    create(:course, :with_full_time_sites, :open, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :open, name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, :open, name: "Computing", course_code: "L364")
  end

  def and_there_are_courses_that_are_closed_for_applications
    create(:course, :with_full_time_sites, :closed, name: "Dance", course_code: "C115")
    create(:course, :with_full_time_sites, :closed, name: "Physics", course_code: "3CXN")
  end

  def given_there_are_courses_with_special_education_needs
    create(:course, :with_full_time_sites, :with_special_education_needs, name: "Biology SEND", course_code: "S872")
    create(:course, :with_full_time_sites, :with_special_education_needs, name: "Chemistry SEND", course_code: "K592")
    create(:course, :with_full_time_sites, :with_special_education_needs, name: "Computing SEND", course_code: "L364")
  end

  def and_there_are_courses_that_with_no_special_education_needs
    create(:course, :with_full_time_sites, is_send: false, can_sponsor_student_visa: false, name: "Dance", course_code: "C115")
    create(:course, :with_full_time_sites, is_send: false, name: "Physics", course_code: "3CXN")
  end

  def and_there_are_courses_that_do_not_sponsor_visa
    create(:course, :with_full_time_sites, can_sponsor_skilled_worker_visa: false, can_sponsor_student_visa: false, name: "Dance", course_code: "C115")
  end

  def and_i_filter_by_courses_that_sponsor_visa
    check "Only show courses with visa sponsorship", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_only_by_part_time_courses
    uncheck "Full time (12 months)", visible: :all
    check "Part time (18 to 24 months)", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_only_by_full_time_courses
    uncheck "Part time (18 to 24 months)", visible: :all
    check "Full time (12 months)", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_part_time_and_full_time_courses
    check "Part time (18 to 24 months)", visible: :all
    check "Full time (12 months)", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_qts_only_courses
    check "QTS only", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_qts_with_pgce_or_pgde_courses
    check "QTS with PGCE or PGDE", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_courses_open_for_applications
    check "Only show courses open for applications", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_courses_with_special_education_needs
    check "Only show courses with a SEND specialism", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_only_courses_that_sponsor_visa
    with_retry do
      expect(results).to have_content("Biology (S872")
      expect(results).to have_content("Chemistry (K592)")
      expect(results).to have_content("Computing (L364)")
      expect(results).to have_no_content("Dance (C115)")
    end
  end

  def then_i_see_only_part_time_courses
    with_retry do
      expect(results).to have_content("Chemistry (K592)")
      expect(results).to have_content("Computing (L364)")
      expect(results).to have_no_content("Biology (S872)")
    end
  end

  def and_the_part_time_filter_is_checked
    expect(page).to have_checked_field("Part time (18 to 24 months)", visible: :all)
  end

  def then_i_see_only_full_time_courses
    with_retry do
      expect(results).to have_content("Biology (S872)")
      expect(results).to have_content("Computing (L364)")
      expect(results).to have_no_content("Chemistry (K592)")
    end
  end

  def and_the_full_time_filter_is_checked
    expect(page).to have_checked_field("Full time (12 months)", visible: :all)
  end

  def then_i_see_all_courses_containing_all_study_types
    with_retry do
      expect(results).to have_content("Biology (S872)")
      expect(results).to have_content("Computing (L364)")
      expect(results).to have_content("Chemistry (K592)")
    end
  end

  def then_i_see_only_qts_only_courses
    with_retry do
      expect(results).to have_content("Biology (S872)")
      expect(results).to have_no_content("Chemistry (K592)")
      expect(results).to have_no_content("Computing (L364)")
      expect(results).to have_no_content("Dance (C115)")
      expect(results).to have_no_content("Physics (3CXN)")
      expect(results).to have_no_content("Mathemathics (4RTU)")
    end
  end

  def and_the_qts_only_filter_is_checked
    expect(page).to have_checked_field("QTS only", visible: :all)
  end

  def then_i_see_only_qts_with_pgce_or_pgde_courses
    with_retry do
      expect(results).to have_content("Chemistry (K592)")
      expect(results).to have_content("Computing (L364)")
      expect(results).to have_no_content("Biology (S872)")
      expect(results).to have_no_content("Dance (C115)")
      expect(results).to have_no_content("Physics (3CXN)")
      expect(results).to have_no_content("Mathemathics (4RTU)")
    end
  end

  def and_the_qts_with_pgce_or_pgde_filter_is_checked
    expect(page).to have_checked_field("QTS with PGCE or PGDE", visible: :all)
  end

  def then_i_see_only_courses_with_special_education_needs
    with_retry do
      expect(results).to have_content("Biology SEND (S872")
      expect(results).to have_content("Chemistry SEND (K592)")
      expect(results).to have_content("Computing SEND (L364)")
      expect(results).to have_no_content("Dance (C115)")
      expect(results).to have_no_content("Physics (3CXN)")
    end
  end

  def then_i_see_only_courses_that_are_open_for_applications
    with_retry do
      expect(results).to have_content("Biology (S872)")
      expect(results).to have_content("Chemistry (K592)")
      expect(results).to have_content("Computing (L364)")
      expect(results).to have_no_content("Dance (C115)")
      expect(results).to have_no_content("Physics (3CXN)")
    end
  end

  def and_the_visa_sponsorship_filter_is_checked
    expect(page).to have_checked_field("Only show courses with visa sponsorship", visible: :all)
  end

  def and_the_open_for_application_filter_is_checked
    expect(page).to have_checked_field("Only show courses open for applications", visible: :all)
  end

  def and_the_special_education_needs_filter_is_checked
    expect(page).to have_checked_field("Only show courses with a SEND specialism", visible: :all)
  end

  def given_there_are_courses_offering_online_interviews
    create(:course, :with_full_time_sites, name: "Biology Online", course_code: "BOL1").tap do |course|
      create(:course_enrichment, :published, :v2, course:, interview_location: "online")
    end

    create(:course, :with_full_time_sites, name: "Chemistry Both", course_code: "CBOT").tap do |course|
      create(:course_enrichment, :published, :v2, course:, interview_location: "both")
    end
  end

  def and_there_are_courses_that_offer_in_person_only_interviews
    create(:course, :with_full_time_sites, name: "Physics In person", course_code: "PIP1").tap do |course|
      create(:course_enrichment, :published, :v2, course:, interview_location: "in person")
    end

    create(:course, :with_full_time_sites, name: "Draft Only Online", course_code: "DOON").tap do |course|
      create(:course_enrichment, :initial_draft, :v2, course:, interview_location: "online")
    end
  end

  def and_i_filter_by_online_interviews
    check "Only show courses that offer online interviews", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_only_courses_with_online_interviews
    with_retry do
      expect(results).to have_content("Biology Online (BOL1)")
      expect(results).to have_content("Chemistry Both (CBOT)")
      expect(results).to have_no_content("Physics In person (PIP1)")
      expect(results).to have_no_content("Draft Only Online (DOON)")
    end
  end

  def and_the_online_interviews_filter_is_checked
    expect(page).to have_checked_field("Only show courses that offer online interviews", visible: :all)
  end
end
