require "rails_helper"

RSpec.describe "Support console Candidate email alerts" do
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  scenario "admin sees email alerts for a candidate" do
    when_a_candidate_with_email_alerts_exists
    and_i_visit_the_candidate_email_alerts
    then_i_see_the_page_title
    and_i_see_the_tab_navigation
    then_i_see_the_email_alerts
  end

  scenario "admin unsubscribes an active alert" do
    when_a_candidate_with_email_alerts_exists
    and_i_visit_the_candidate_email_alerts
    and_i_click_unsubscribe
    then_i_see_the_confirmation_page
    and_i_confirm_unsubscribe
    then_i_see_the_success_flash
    and_the_alert_is_unsubscribed
  end

  scenario "empty state when no alerts" do
    when_a_candidate_without_email_alerts_exists
    and_i_visit_the_candidate_email_alerts
    then_i_see_the_empty_state
  end

  def when_a_candidate_with_email_alerts_exists
    @candidate = create(:candidate)
    @active_alert = create(:email_alert, candidate: @candidate, location_name: "London")
    @unsubscribed_alert = create(:email_alert, candidate: @candidate, location_name: "Manchester", unsubscribed_at: 1.day.ago)
  end

  def when_a_candidate_without_email_alerts_exists
    @candidate = create(:candidate)
  end

  def and_i_visit_the_candidate_email_alerts
    visit support_candidate_email_alerts_path(@candidate)
  end

  def then_i_see_the_page_title
    expect(page).to have_title("Email alerts")
  end

  def and_i_see_the_tab_navigation
    expect(page).to have_link("Details", href: details_support_candidate_path(@candidate))
    expect(page).to have_link("Saved courses", href: saved_courses_support_candidate_path(@candidate))
    expect(page).to have_link("Email alerts", href: support_candidate_email_alerts_path(@candidate))
  end

  def then_i_see_the_email_alerts
    expect(page).to have_content(@candidate.email_address)
    expect(page).to have_content("Active")
    expect(page).to have_content("Unsubscribed")
    expect(page).to have_content("London")
    expect(page).to have_content("Manchester")
  end

  def and_i_click_unsubscribe
    click_link_or_button("Unsubscribe")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content("Are you sure you want to unsubscribe this email alert?")
  end

  def and_i_confirm_unsubscribe
    click_link_or_button("Unsubscribe")
  end

  def then_i_see_the_success_flash
    expect(page).to have_content("Email alert successfully unsubscribed")
  end

  def and_the_alert_is_unsubscribed
    expect(@active_alert.reload.unsubscribed_at).to be_present
  end

  def then_i_see_the_empty_state
    expect(page).to have_content("This candidate has no email alerts.")
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end
end
