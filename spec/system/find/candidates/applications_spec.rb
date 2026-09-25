# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Applications", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
  end

  scenario "Signed in candidate follows the Applications nav item to Apply" do
    when_i_sign_in
    and_i_click_applications_in_the_nav
    then_i_see_the_interruption_page
    and_the_continue_button_links_to_apply
  end

  scenario "Navigation does not show Applications link when signed out" do
    when_i_visit_the_homepage
    then_i_do_not_see_applications_in_nav
  end

  def when_i_sign_in
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def when_i_visit_the_homepage
    visit "/"
  end

  def and_i_click_applications_in_the_nav
    click_link_or_button "Applications"
  end

  def then_i_see_the_interruption_page
    expect(page).to have_title("View and manage your applications - Find teacher training courses - GOV.UK")
    expect(page).to have_css("h1", text: "View and manage your applications")
    expect(page).to have_content("Continue to the Apply for teacher training website to view and manage your applications.")
    expect(page).to have_content("You’ll need to sign in to use this service. If you do not already have sign in details, you’ll be able to create them.")
  end

  def and_the_continue_button_links_to_apply
    expect(page).to have_link(
      "Continue to the Apply for teacher training website",
      href: "#{Settings.apply_base_url}/candidate/account",
    )
  end

  def then_i_do_not_see_applications_in_nav
    expect(page).not_to have_link("Applications")
  end
end
