require "rails_helper"

RSpec.describe "View pages" do
  scenario "As a Candidate, I can log into Find" do
    visit "/"

    click_link_or_button "Login"

    expect(page).to have_content("You're logged in!")

    click_link_or_button "Logout"

    expect(page).to have_no_content("You're logged in!")
    expect(page).to have_button("Login")
  end
end
