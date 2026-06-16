# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Visit Email alerts from email body", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    FeatureFlag.activate(:email_alerts)
    CandidateAuthHelper.mock_auth
  end

  scenario "Viewing email alerts index from email unauthenticated" do
    when_i_visit_email_alerts
    then_i_am_shown_a_sign_in_page
    when_i_click_sign_in_button
    then_i_am_redirected_to_the_email_alerts
  end

  def then_i_am_redirected_to_the_email_alerts
    expect(page).to have_current_path("/candidate/email-alerts")
  end

  def then_i_am_shown_a_sign_in_page
    expect(page).to have_content("Sign in to view all your email alerts")
  end

  def when_i_click_sign_in_button
    all(:link_or_button, "Sign in").last.click
    expect(page).to have_content("You have been successfully signed in.")
  end

  def when_i_visit_email_alerts
    visit find_candidate_email_alerts_path
  end
end
