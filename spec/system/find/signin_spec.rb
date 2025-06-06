require "rails_helper"

RSpec.describe "View pages" do
  scenario "As a Candidate, I can log into and out of Find" do
    given_candidate_accounts_is_active
    when_i_visit_the_find_homepage
    then_i_see_a_login_button

    when_i_click_login
    then_i_see_that_i_am_logged_in

    when_i_click_logout
    then_i_see_that_i_am_logged_out
  end

  def given_candidate_accounts_is_active
    FeatureFlag.activate(:candidate_accounts)
  end

  def when_i_visit_the_find_homepage
    visit "/"
  end

  def then_i_see_a_login_button
    expect(page).to have_button("Login")
  end

  def when_i_click_login
    click_link_or_button "Login"
  end

  def then_i_see_that_i_am_logged_in
    expect(page).to have_content("You're logged in!")
  end

  def when_i_click_logout
    click_link_or_button "Logout"
  end

  def then_i_see_that_i_am_logged_out
    expect(page).to have_no_content("You're logged in!")
    expect(page).to have_button("Login")
  end
end
