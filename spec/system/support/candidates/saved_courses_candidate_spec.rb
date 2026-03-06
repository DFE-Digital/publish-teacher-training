require "rails_helper"

RSpec.describe "Support console Candidates saved courses" do
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  scenario "user sees candidates details" do
    when_a_candidates_exist
    and_i_visit_the_candidate_details
    then_i_see_the_saved_courses_of_the_candidate
  end

  scenario "user sees an empty state when candidate has no saved courses" do
    when_a_candidate_exists_with_no_saved_courses
    and_i_visit_the_candidate_details
    then_i_see_no_saved_courses_message
  end

  scenario "saved courses are ordered by most recently saved first" do
    when_a_candidate_exists_with_saved_courses_in_different_created_order
    and_i_visit_the_candidate_details
    then_i_see_saved_courses_ordered_by_most_recent_first
  end

  def when_a_candidates_exist
    @candidate = create(:candidate)

    course = create(:course)
    @saved_course = create(:saved_course, candidate: @candidate, course:)
  end

  def when_a_candidate_exists_with_no_saved_courses
    @candidate = create(:candidate)
  end

  def when_a_candidate_exists_with_saved_courses_in_different_created_order
    @candidate = create(:candidate)
    @older_saved_course = create(:saved_course, candidate: @candidate, created_at: 2.days.ago)
    @newer_saved_course = create(:saved_course, candidate: @candidate, created_at: 1.day.ago)
  end

  def and_i_visit_the_candidate_details
    visit saved_courses_support_candidate_path(@candidate)
  end

  def then_i_see_the_saved_courses_of_the_candidate
    expect(page).to have_content(@saved_course.course.name)
    expect(page).to have_content(@saved_course.course.course_code)
    expect(page).to have_content(@saved_course.course.provider_name)
    expect(page).to have_content(@saved_course.created_at.to_fs(:govuk_date_and_time))
  end

  def then_i_see_no_saved_courses_message
    expect(page).to have_text(/This candidate hasn.?t saved any courses yet\./)
  end

  def then_i_see_saved_courses_ordered_by_most_recent_first
    within("table tbody") do
      rows = all("tr")
      expect(rows.first).to have_text(@newer_saved_course.course.name)
      expect(rows.last).to have_text(@older_saved_course.course.name)
    end
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end
end
