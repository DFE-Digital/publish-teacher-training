require "rails_helper"

RSpec.describe "Deleting a saved course note", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    FeatureFlag.activate(:bursaries_and_scholarships_announced)
    CandidateAuthHelper.mock_auth
  end

  scenario "A candidate can delete a note for a saved course" do
    given_i_am_signed_in
    and_i_have_a_saved_course_with_a_note

    when_i_visit_my_saved_courses
    then_i_can_delete_the_note
  end

  scenario "A candidate sees an error when deleting a note fails" do
    given_i_am_signed_in
    and_i_have_a_saved_course_with_a_note

    when_i_visit_my_saved_courses
    and_the_note_is_removed_before_i_submit_delete
    then_i_see_a_failed_to_delete_note_message
  end

  scenario "Deleting a note fires the note deleted analytics event" do
    analytics_event = instance_double(Find::Analytics::CandidateNoteDeletedEvent)
    allow(analytics_event).to receive(:send_event)
    allow(Find::Analytics::CandidateNoteDeletedEvent).to receive(:new).and_return(analytics_event)

    given_i_am_signed_in
    and_i_have_a_saved_course_with_a_note

    when_i_visit_my_saved_courses
    then_i_can_delete_the_note

    expect(analytics_event).to have_received(:send_event).at_least(:once)
  end

  def given_i_am_signed_in
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def and_i_have_a_saved_course_with_a_note
    subject_with_incentives = create(:secondary_subject, :physics, bursary_amount: 20_000, scholarship: 22_000)
    course = create(
      :course,
      :secondary,
      :open,
      :published,
      name: "Physics",
      course_code: "S252",
      provider: build(:provider, provider_name: "Best Practice Network", provider_code: "RO1"),
      subjects: [subject_with_incentives],
      master_subject_id: subject_with_incentives.id,
      enrichments: [create(:course_enrichment, :published, fee_uk_eu: 9535, fee_international: 17_500)],
    )

    @saved_course = create(:saved_course, candidate: Candidate.first, course: course, note: "Note to delete")
  end

  def when_i_visit_my_saved_courses
    click_link_or_button "Saved courses"
    expect(page).to have_current_path(find_candidate_saved_courses_path)
  end

  def then_i_can_delete_the_note
    within(all(".govuk-summary-card").first) do
      within ".govuk-summary-list__actions" do
        click_button "Delete"
      end
    end

    expect(page).to have_current_path(find_candidate_saved_courses_path)
    expect(page).to have_content("Note deleted")
    expect(page).to have_content("Your note for Best Practice Network - Physics (S252) has been deleted.")

    within(all(".govuk-summary-card").first) do
      expect(page).to have_link("Add a note")
      expect(page).not_to have_content("Note to delete")
    end
  end

  def and_the_note_is_removed_before_i_submit_delete
    @saved_course.update!(note: nil)
  end

  def then_i_see_a_failed_to_delete_note_message
    within(all(".govuk-summary-card").first) do
      within ".govuk-summary-list__actions" do
        click_button "Delete"
      end
    end

    expect(page).to have_current_path(find_candidate_saved_courses_path)
    expect(page).to have_content("Failed to delete note")
  end
end
