require "rails_helper"

RSpec.describe "Candidate Authentication Error" do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_error_auth
  end

  scenario "Authentication error page when login fails" do
    when_i_visit_the_find_homepage
    when_i_click_login
    then_i_see_an_error_message
  end

  def when_i_visit_the_find_homepage
    visit "/"
  end

  def when_i_click_login
    click_link_or_button "Sign in"
  end

  def then_i_see_an_error_message
    expect(page).to have_content("Authentication error")
    expect(page).to have_content("There has been a problem authenticating this login. Please try again.")
  end
end
