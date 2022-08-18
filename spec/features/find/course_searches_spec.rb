require "rails_helper"

feature "course searches", type: :feature do
  scenario "Navigate to /find" do
    when_i_visit_the_search_page
    then_i_should_see_the_page_title
    and_i_should_see_the_page_heading
    and_i_see_the_three_search_options
  end

  def when_i_visit_the_search_page
    courses_by_location_or_training_provider_page.load
  end

  def then_i_should_see_the_page_title
    expect(courses_by_location_or_training_provider_page.title).to have_content "Find courses by location or by training provider"
  end

  def and_i_should_see_the_page_heading
    expect(courses_by_location_or_training_provider_page.heading).to have_content "Find courses by location or by training provider"
  end

  def and_i_see_the_three_search_options
    expect(courses_by_location_or_training_provider_page).to have_by_city_town_or_postcode_radio
    expect(courses_by_location_or_training_provider_page).to have_across_england
    expect(courses_by_location_or_training_provider_page).to have_by_school_uni_or_provider
  end
end
