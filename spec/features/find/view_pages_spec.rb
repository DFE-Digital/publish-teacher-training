require "rails_helper"

feature "View pages", type: :feature do

  scenario "Navigate to /cookies" do
    visit "/find/cookies"
    expect(page).to have_selector("h1", text: "Cookies")
  end

  scenario "Navigate to /terms-conditions" do
    visit "find/terms-conditions"
    expect(page) .to have_selector("h1", text: "Terms and conditions")
  end

  scenario "Navigate to /privacy-policy" do
    visit "find/privacy-policy"
    expect(page) .to have_selector("h1", text: "Privacy policy")
  end

  scenario "Navigate to /accessibility" do
    visit "find/accessibility"
    expect(page) .to have_selector("h1", text: "Accessibility statement for Find postgraduate teacher trainin")
  end
end
