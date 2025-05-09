# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Secondary subjects quick link", service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  context "when filter by subjects" do
    before do
      given_there_are_courses_with_secondary_subjects
      when_subjects_are_grouped_by_subject_groups
      when_i_visit_the_find_homepage
    end

    scenario "filter by a secondary course" do
      click_link_or_button "Browse secondary courses"
      when_i_select_chemistry
      then_i_see_only_see_chemistry_courses
    end

    scenario "filter all secondary courses" do
      click_link_or_button "Browse secondary courses"
      when_i_select_all_secondary_courses
      then_i_see_all_secondary_courses
    end

    scenario "errors when no courses are selected" do
      click_link_or_button "Browse secondary courses"
      click_link_or_button "Find secondary courses"
      then_i_see_errors
    end

    scenario "check for backlink presence and navigation on secondary page" do
      click_link_or_button "Browse secondary courses"
      then_i_see_backlink_to_find_homepage
      click_link_or_button "Back"
      then_i_am_on_the_find_homepage
    end
  end

  def given_there_are_courses_with_secondary_subjects
    create(:course, :open, :with_full_time_sites, :secondary, name: "Biology", course_code: "S872", subjects: [find_or_create(:secondary_subject, :biology)])
    create(:course, :open, :with_full_time_sites, :secondary, name: "Chemistry", course_code: "K592", subjects: [find_or_create(:secondary_subject, :chemistry)])
    create(:course, :open, :with_full_time_sites, :secondary, name: "Computing", course_code: "L364", subjects: [find_or_create(:secondary_subject, :computing)])
    create(:course, :open, :with_full_time_sites, :secondary, name: "Mathematics", course_code: "4RTU", subjects: [find_or_create(:secondary_subject, :mathematics)])
  end

  def when_subjects_are_grouped_by_subject_groups
    group = create(:subject_group, name: "Science, technology, engineering and mathematics (STEM)")

    find_or_create(:secondary_subject, :biology).update(subject_group: group)
    find_or_create(:secondary_subject, :chemistry).update(subject_group: group)
    find_or_create(:secondary_subject, :computing).update(subject_group: group)
    find_or_create(:secondary_subject, :mathematics).update(subject_group: group)
  end

  def when_i_visit_the_find_homepage
    visit find_root_path
  end

  def when_i_select_chemistry
    check "Chemistry"
    click_link_or_button "Find secondary courses"
  end

  def then_i_see_only_see_chemistry_courses
    expect(page).to have_content("1 course found")
  end

  def then_i_see_errors
    expect(page).to have_content("Select at least one type of secondary course")
  end

  def when_i_select_all_secondary_courses
    check "Biology"
    check "Chemistry"
    check "Computing"
    check "Mathematics"
    click_link_or_button "Find secondary courses"
  end

  def then_i_see_all_secondary_courses
    expect(page).to have_content("4 courses found")
  end

  def then_i_see_backlink_to_find_homepage
    expect(page).to have_link("Back", href: find_root_path)
  end

  def then_i_am_on_the_find_homepage
    expect(page).to have_current_path(find_root_path)
  end
end
