require "rails_helper"

RSpec.describe "Support console Candidates notes" do
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  scenario "user sees only notes saved by the candidate" do
    given_a_candidate_with_a_mix_of_noted_and_non_noted_saved_courses
    when_i_visit_the_candidate_notes_page
    then_i_see_only_noted_courses_for_that_candidate
  end

  scenario "notes are ordered by most recently updated first" do
    given_a_candidate_with_notes_in_different_updated_order
    when_i_visit_the_candidate_notes_page
    then_i_see_notes_ordered_by_most_recently_updated_first
  end

  scenario "user sees an empty state when candidate has no notes" do
    given_a_candidate_with_no_notes
    when_i_visit_the_candidate_notes_page
    then_i_see_no_notes_message
  end

  scenario "user sees links to details and saved courses tabs" do
    given_a_candidate_with_a_note
    when_i_visit_the_candidate_notes_page
    then_i_see_links_to_details_and_saved_courses_tabs
  end

  def given_a_candidate_with_a_mix_of_noted_and_non_noted_saved_courses
    @candidate = create(:candidate)
    @noted_course = create(:course, name: "Course with note")
    @saved_with_note = create(:saved_course, candidate: @candidate, course: @noted_course, note: "Strong preference")
    @course_without_note = create(:course, name: "Course without note")
    create(:saved_course, candidate: @candidate, course: @course_without_note, note: nil)
    @course_with_blank_note = create(:course, name: "Course with blank note")
    create(:saved_course, candidate: @candidate, course: @course_with_blank_note, note: "")
    @other_candidate_course = create(:course, name: "Other candidate note")
    create(:saved_course, candidate: create(:candidate), course: @other_candidate_course, note: "Not this user")
  end

  def given_a_candidate_with_notes_in_different_updated_order
    @candidate = create(:candidate)
    @older_note = create(:saved_course, candidate: @candidate, note: "Older note", updated_at: 2.days.ago)
    @newer_note = create(:saved_course, candidate: @candidate, note: "Newer note", updated_at: 1.hour.ago)
  end

  def given_a_candidate_with_no_notes
    @candidate = create(:candidate)
  end

  def given_a_candidate_with_a_note
    @candidate = create(:candidate)
    create(:saved_course, candidate: @candidate, note: "A note")
  end

  def when_i_visit_the_candidate_notes_page
    visit notes_support_candidate_path(@candidate)
  end

  def then_i_see_only_noted_courses_for_that_candidate
    expect(page).to have_content(@saved_with_note.course.name)
    expect(page).to have_content(@saved_with_note.note)
    expect(page).not_to have_content(@course_without_note.name)
    expect(page).not_to have_content(@course_with_blank_note.name)
    expect(page).not_to have_content(@other_candidate_course.name)
  end

  def then_i_see_notes_ordered_by_most_recently_updated_first
    within("table tbody") do
      rows = all("tr")
      expect(rows.first).to have_text(@newer_note.note)
      expect(rows.last).to have_text(@older_note.note)
    end
  end

  def then_i_see_no_notes_message
    expect(page).to have_text(/This candidate hasn.?t added any notes yet\./)
  end

  def then_i_see_links_to_details_and_saved_courses_tabs
    expect(page).to have_link("Details", href: details_support_candidate_path(@candidate))
    expect(page).to have_link("Saved courses", href: saved_courses_support_candidate_path(@candidate))
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end
end
