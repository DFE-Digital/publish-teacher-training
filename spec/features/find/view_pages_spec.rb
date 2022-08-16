require "rails_helper"

feature "View pages", type: :feature do
  scenario "Navigate to /find" do
    when_i_visit_the_search_page
    then_i_should_see_the_page_title
    and_i_see_the_three_correct_radios
  end

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

def when_i_visit_the_search_page
  courses_by_location_or_training_provider_page.load
end

def then_i_should_see_the_page_title
  expect(courses_by_location_or_training_provider_page).to have_text "Find courses by location or by training provider"
end

def and_i_see_the_three_correct_radios
  expect(courses_by_location_or_training_provider_page).to have_by_city_town_or_postcode_radio
  expect(courses_by_location_or_training_provider_page).to have_across_england
  expect(courses_by_location_or_training_provider_page).to have_by_school_uni_or_provider
end
