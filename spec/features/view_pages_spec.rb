require "rails_helper"

feature "View pages", type: :feature do
  scenario "Environment label and class are read from settings" do
    visit "/cookies"
    expect(page).to have_selector(".govuk-phase-banner__content__tag", text: Settings.environment.label)
    expect(page).to have_selector(".app-header--#{Settings.environment.name}")
  end

  scenario "Navigate to /cookies" do
    visit "/cookies"
    expect(page).to have_selector("h1", text: "Cookies")
  end

  scenario "Navigate to /terms-conditions" do
    visit "/terms-conditions"
    expect(page) .to have_selector("h1", text: "Terms and conditions")
  end

  scenario "Navigate to /privacy-policy" do
    visit "/privacy-policy"
    expect(page) .to have_selector("h1", text: "Privacy policy")
  end

  scenario "Navigate to /guidance" do
    visit "/guidance"
    expect(page) .to have_selector("h1", text: "Guidance for Publish teacher training courses")
  end

  scenario "Navigate to /accessibility" do
    visit "/accessibility"
    expect(page) .to have_selector("h1", text: "Accessibility statement for Publish teacher training courses")
  end
end
