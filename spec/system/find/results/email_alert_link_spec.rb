# frozen_string_literal: true

require "rails_helper"
require_relative "./filtering_helper"

RSpec.describe "Email alert link on results page", service: :find do
  include FilteringHelper

  before do
    FeatureFlag.activate(:candidate_accounts)
    FeatureFlag.activate(:email_alerts)
    CandidateAuthHelper.mock_auth
    given_there_are_courses_with_secondary_subjects
  end

  scenario "Signed in user with filters applied sees the email alert link" do
    when_i_sign_in
    when_i_visit_results_with_subject_filter
    then_i_see_the_email_alert_link
  end

  scenario "Signed out user does not see the email alert link" do
    when_i_visit_results_with_subject_filter
    then_i_do_not_see_the_email_alert_link
  end

  scenario "Email alert link is hidden when feature flag is off" do
    FeatureFlag.deactivate(:email_alerts)
    when_i_sign_in
    when_i_visit_results_with_subject_filter
    then_i_do_not_see_the_email_alert_link
  end

  scenario "Email alert link is hidden when no filters are applied" do
    when_i_sign_in
    when_i_visit_the_find_results_page
    then_i_do_not_see_the_email_alert_link
  end

  scenario "Email alert link is hidden when an active alert exists for the search" do
    when_i_sign_in
    and_i_have_an_active_alert_for_the_search
    when_i_visit_results_with_subject_filter
    then_i_do_not_see_the_email_alert_link
  end

  scenario "Email alert link is shown when alert for the search has been unsubscribed" do
    when_i_sign_in
    and_i_have_an_unsubscribed_alert_for_the_search
    when_i_visit_results_with_subject_filter
    then_i_see_the_email_alert_link
  end

  def when_i_sign_in
    visit "/"
    click_link_or_button "Sign in"
  end

  def when_i_visit_results_with_subject_filter
    biology = Subject.find_by(subject_name: "Biology")
    visit find_results_path(subjects: [biology.subject_code])
  end

  def then_i_see_the_email_alert_link
    expect(page).to have_link("Email me courses like this")
  end

  def then_i_do_not_see_the_email_alert_link
    expect(page).not_to have_link("Email me courses like this")
  end

  def candidate
    Candidate.first
  end

  def and_i_have_an_active_alert_for_the_search
    biology = Subject.find_by(subject_name: "Biology")

    create(
      :email_alert,
      candidate:,
      subjects: [biology.subject_code],
      search_attributes: search_attributes_for_subject_filter,
    )
  end

  def and_i_have_an_unsubscribed_alert_for_the_search
    biology = Subject.find_by(subject_name: "Biology")

    alert = create(
      :email_alert,
      candidate:,
      subjects: [biology.subject_code],
      search_attributes: search_attributes_for_subject_filter,
    )
    alert.unsubscribe!
  end

  def search_attributes_for_subject_filter
    { "minimum_degree_required" => "show_all_courses" }
  end
end
