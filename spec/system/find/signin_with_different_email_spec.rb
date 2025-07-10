require "rails_helper"

RSpec.describe "Candidate Sign in" do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth(email_address: new_email_address)
  end

  scenario "As a Candidate, I can log into and out of Find" do
    when_i_visit_the_find_homepage

    when_i_click_login

    then_i_see_that_i_am_logged_in

    when_i_click_logout
    then_i_see_that_i_am_logged_out
    and_the_candidate_email_address_is_updated
  end

  def when_i_visit_the_find_homepage
    visit "/"
  end

  def when_i_click_login
    click_link_or_button "Sign in"
  end

  def then_i_see_that_i_am_logged_in
    expect(page).to have_content("You have been successfully signed in.")
  end

  def when_i_click_logout
    click_link_or_button "Sign out"
  end

  def then_i_see_that_i_am_logged_out
    expect(page).to have_no_content("You have been successfully signed in.")
    expect(page).to have_content("You have been successfully signed out.")
    expect(page).to have_button("Sign in")
  end

  def and_the_candidate_email_address_is_updated
    expect(Candidate.last.email_address).to eq(new_email_address)
  end

  def new_email_address
    @new_email_address = "updated@example.com"
  end
end
