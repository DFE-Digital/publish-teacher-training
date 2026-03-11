require "rails_helper"

RSpec.describe "Support console Candidates details" do
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  scenario "user sees candidates details" do
    when_a_candidates_exist
    and_i_visit_the_candidate_details
    then_i_see_the_details_of_the_candidate
  end

  scenario "user sees tabs to saved courses and notes" do
    when_a_candidates_exist
    and_i_visit_the_candidate_details
    then_i_see_tabs_to_saved_courses_and_notes
  end

  scenario "user sees the last login date when a session exists" do
    when_a_logged_in_candidate_exists
    and_i_visit_the_candidate_details
    then_i_see_the_last_login_date
  end

  def when_a_candidates_exist
    @candidate = create(:candidate)
  end

  def when_a_logged_in_candidate_exists
    @candidate = create(:candidate, :logged_in)
  end

  def and_i_visit_the_candidate_details
    visit details_support_candidate_path(@candidate)
  end

  def then_i_see_the_details_of_the_candidate
    expect(page).to have_content(@candidate.email_address)
    expect(page).to have_content(@candidate.created_at.to_fs(:govuk_date_and_time))
    expect(page).to have_content("Never logged in")
    expect(page).to have_link("Email alerts", href: support_candidate_email_alerts_path(@candidate))
  end

  def then_i_see_tabs_to_saved_courses_and_notes
    expect(page).to have_link("Saved courses", href: saved_courses_support_candidate_path(@candidate))
    expect(page).to have_link("Notes", href: notes_support_candidate_path(@candidate))
  end

  def then_i_see_the_last_login_date
    expect(page).to have_content(@candidate.sessions.last.created_at.to_fs(:govuk_date_and_time))
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end
end
