require "rails_helper"

RSpec.describe "Support console Candidates notes" do
  let(:user) { create(:user, :admin) }

  before { sign_in_system_test(user:) }

  scenario "user sees only notes saved by the candidate" do
    candidate = create(:candidate)
    noted_course = create(:course, name: "Course with note")
    saved_with_note = create(:saved_course, candidate:, course: noted_course, note: "Strong preference")
    no_note_course = create(:course, name: "Course without note")
    create(:saved_course, candidate:, course: no_note_course, note: nil)
    blank_note_course = create(:course, name: "Course with blank note")
    create(:saved_course, candidate:, course: blank_note_course, note: "")
    other_candidate_course = create(:course, name: "Other candidate note")
    create(:saved_course, candidate: create(:candidate), course: other_candidate_course, note: "Not this user")

    visit notes_support_candidate_path(candidate)

    expect(page).to have_content(saved_with_note.course.name)
    expect(page).to have_content(saved_with_note.note)
    expect(page).not_to have_content(no_note_course.name)
    expect(page).not_to have_content(blank_note_course.name)
    expect(page).not_to have_content(other_candidate_course.name)
  end

  scenario "notes are ordered by most recently updated first" do
    candidate = create(:candidate)
    older_note = create(:saved_course, candidate:, note: "Older note", updated_at: 2.days.ago)
    newer_note = create(:saved_course, candidate:, note: "Newer note", updated_at: 1.hour.ago)

    visit notes_support_candidate_path(candidate)

    within("table tbody") do
      rows = all("tr")
      expect(rows.first).to have_text(newer_note.note)
      expect(rows.last).to have_text(older_note.note)
    end
  end

  scenario "user sees an empty state when candidate has no notes" do
    candidate = create(:candidate)

    visit notes_support_candidate_path(candidate)

    expect(page).to have_text(/This candidate hasn.?t added any notes yet\./)
  end

  scenario "user sees links to details and saved courses tabs" do
    candidate = create(:candidate)
    create(:saved_course, candidate:, note: "A note")

    visit notes_support_candidate_path(candidate)

    expect(page).to have_link("Details", href: details_support_candidate_path(candidate))
    expect(page).to have_link("Saved courses", href: saved_courses_support_candidate_path(candidate))
  end
end
