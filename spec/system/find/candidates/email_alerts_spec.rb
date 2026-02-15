# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Email alerts", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    FeatureFlag.activate(:email_alerts)
    CandidateAuthHelper.mock_auth
  end

  scenario "Navigation shows Email alerts link when authenticated" do
    when_i_sign_in
    then_i_see_email_alerts_in_nav
  end

  scenario "Navigation does not show Email alerts link when signed out" do
    when_i_visit_the_homepage
    then_i_do_not_see_email_alerts_in_nav
  end

  scenario "Navigation does not show Email alerts when feature flag is off" do
    FeatureFlag.deactivate(:email_alerts)
    when_i_sign_in
    then_i_do_not_see_email_alerts_in_nav
  end

  scenario "Empty state is shown when there are no email alerts" do
    when_i_sign_in
    when_i_visit_email_alerts
    then_i_see_empty_state
  end

  scenario "Email alerts are displayed with summary cards" do
    when_i_sign_in
    and_i_have_email_alerts
    when_i_visit_email_alerts

    then_i_see_my_email_alerts
    then_i_see_unsubscribe_links
  end

  scenario "Creating an email alert from the new page" do
    when_i_sign_in
    when_i_visit_new_email_alert_with_params
    then_i_see_the_confirmation_page
    when_i_click_set_up_email_alert

    then_i_see_success_banner
    then_the_email_alert_is_created
  end

  scenario "Unsubscribing from an email alert (authenticated)" do
    when_i_sign_in
    and_i_have_email_alerts
    when_i_visit_email_alerts
    when_i_click_unsubscribe

    then_i_see_unsubscribe_confirmation_page
    when_i_confirm_unsubscribe

    then_i_see_unsubscribe_success_banner
    then_the_first_alert_is_unsubscribed
  end

  scenario "Unsubscribing via token from email (no auth required)" do
    when_i_sign_in
    and_i_have_email_alerts
    when_i_visit_token_unsubscribe_link

    then_i_see_token_unsubscribe_confirmation_page
    when_i_confirm_unsubscribe

    then_i_see_homepage
    then_the_biology_alert_is_unsubscribed
  end

  scenario "Token unsubscribe redirects for invalid token" do
    visit find_unsubscribe_email_alert_from_email_path(token: "invalid-token")
    then_i_see_homepage
  end

  scenario "Unsubscribed alerts do not appear in the index" do
    when_i_sign_in
    and_i_have_email_alerts
    and_one_alert_is_unsubscribed
    when_i_visit_email_alerts

    then_i_see_only_active_alerts
  end

  scenario "Creating an alert from the recent searches page" do
    when_i_sign_in
    and_i_have_a_recent_search
    when_i_visit_recent_searches
    when_i_click_set_up_email_alert_on_recent_search

    then_i_see_the_confirmation_page
    when_i_click_set_up_email_alert

    then_the_email_alert_is_created
  end

  scenario "Summary card displays filter details" do
    when_i_sign_in
    and_i_have_an_alert_with_many_filters
    when_i_visit_email_alerts

    then_i_see_filter_details_in_summary_card
  end

  def when_i_sign_in
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def when_i_visit_the_homepage
    visit "/"
  end

  def when_i_visit_email_alerts
    visit find_candidate_email_alerts_path
  end

  def when_i_visit_recent_searches
    visit find_candidate_recent_searches_path
  end

  def candidate
    Candidate.first
  end

  def then_i_see_email_alerts_in_nav
    expect(page).to have_link("Email alerts")
  end

  def then_i_do_not_see_email_alerts_in_nav
    expect(page).not_to have_link("Email alerts")
  end

  def then_i_see_empty_state
    expect(page).to have_content("You have no email alerts")
    expect(page).to have_link("Find a course")
  end

  def when_i_visit_new_email_alert_with_params
    create_subject!("C1", "Biology")
    visit new_find_candidate_email_alert_path(subjects: %w[C1], level: "secondary")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content("Get email alerts for")
    expect(page).to have_content("We'll email you weekly")
    expect(page).to have_button("Set up email alert")
    expect(page).to have_link("Cancel")
  end

  def when_i_click_set_up_email_alert
    click_link_or_button "Set up email alert"
  end

  def then_i_see_success_banner
    expect(page).to have_content("Email alert created")
  end

  def then_the_email_alert_is_created
    expect(candidate.email_alerts.active.count).to eq(1)
  end

  def and_i_have_email_alerts
    create_subject!("C1", "Biology")
    create_subject!("F1", "Chemistry")

    @alert_biology = create(
      :email_alert,
      candidate:,
      subjects: %w[C1],
      location_name: "London",
      radius: 20,
      search_attributes: { "location" => "London" },
    )
    @alert_chemistry = create(
      :email_alert,
      candidate:,
      subjects: %w[F1],
      search_attributes: { "can_sponsor_visa" => "true" },
    )
  end

  def then_i_see_my_email_alerts
    expect(page).to have_content("Biology")
    expect(page).to have_content("Chemistry")
  end

  def then_i_see_unsubscribe_links
    expect(page).to have_link("Unsubscribe", count: 2)
  end

  def when_i_click_unsubscribe
    first(:link, "Unsubscribe").click
  end

  def then_i_see_unsubscribe_confirmation_page
    expect(page).to have_content("Unsubscribe from this email alert")
    expect(page).to have_content("Are you sure you want to unsubscribe?")
    expect(page).to have_button("Unsubscribe")
    expect(page).to have_link("Cancel")
  end

  def when_i_confirm_unsubscribe
    click_link_or_button "Unsubscribe"
  end

  def then_i_see_unsubscribe_success_banner
    expect(page).to have_content("We've unsubscribed you from this email alert")
  end

  def then_the_first_alert_is_unsubscribed
    # first(:link, "Unsubscribe") targets the first card in created_at :desc
    # order — that's @alert_chemistry (created second).
    expect(@alert_chemistry.reload.unsubscribed_at).to be_present
  end

  def then_the_biology_alert_is_unsubscribed
    expect(@alert_biology.reload.unsubscribed_at).to be_present
  end

  def when_i_visit_token_unsubscribe_link
    token = @alert_biology.signed_id(purpose: :unsubscribe, expires_in: 30.days)
    visit find_unsubscribe_email_alert_from_email_path(token:)
  end

  def then_i_see_token_unsubscribe_confirmation_page
    expect(page).to have_content("Unsubscribe from this email alert")
    expect(page).to have_content("Are you sure you want to unsubscribe?")
    expect(page).to have_button("Unsubscribe")
  end

  def then_i_see_homepage
    expect(page).to have_current_path(find_root_path)
  end

  def and_one_alert_is_unsubscribed
    @alert_biology.unsubscribe!
  end

  def then_i_see_only_active_alerts
    expect(page).to have_content("Chemistry")
    expect(page).not_to have_content("Biology")
    expect(page).to have_link("Unsubscribe", count: 1)
  end

  def and_i_have_a_recent_search
    create_subject!("C1", "Biology")

    create(
      :recent_search,
      candidate:,
      subjects: %w[C1],
      search_attributes: { "level" => "secondary" },
    )
  end

  def when_i_click_set_up_email_alert_on_recent_search
    click_link_or_button "Set up email alert"
  end

  def and_i_have_an_alert_with_many_filters
    create_subject!("C1", "Biology")

    create(
      :email_alert,
      candidate:,
      subjects: %w[C1],
      location_name: "Manchester",
      radius: 15,
      search_attributes: {
        "location" => "Manchester",
        "can_sponsor_visa" => "true",
        "funding" => %w[salary],
        "send_courses" => "true",
      },
    )
  end

  def then_i_see_filter_details_in_summary_card
    expect(page).to have_content("Biology")
    expect(page).to have_content("Within 15 miles of Manchester")
    expect(page).to have_content("Visa sponsorship")
    expect(page).to have_content("Salary")
    expect(page).to have_content("SEND courses")
  end

  def create_subject!(code, name)
    return Subject.find_by(subject_code: code) if Subject.exists?(subject_code: code)

    subject_area = SubjectArea.find_or_create_by!(typename: "SecondarySubject", name: "Secondary")
    Subject.create!(subject_code: code, subject_name: name, type: "SecondarySubject", subject_area:)
  end
end
