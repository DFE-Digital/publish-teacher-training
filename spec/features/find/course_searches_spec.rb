require "rails_helper"

feature "course searches", type: :feature do
  scenario "Navigate to /find" do
    when_i_visit_the_search_page
    then_i_should_see_the_page_title
    and_i_should_see_the_page_heading
    and_i_see_the_three_search_options
  end

  scenario "Candidate searches by provider" do
    given_there_are_providers
    and_i_visit_the_search_page
    when_i_select_the_provider_radio_button

    and_i_select_the_provider
    then_i_click_continue
  end

private

  def providers
    @providers ||= create_list(:provider, 3)
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

  def when_i_select_the_provider_radio_button
    courses_by_location_or_training_provider_page.by_school_uni_or_provider.choose
  end

  def and_i_select_the_provider
    options = providers.map { |provider| "#{provider.provider_name} (#{provider.provider_code})" } .sort

    expect(courses_by_location_or_training_provider_page.provider_options).to have_content options.join(" ")

    courses_by_location_or_training_provider_page.provider_options.select(options.sample)
  end

  def then_i_click_continue
    courses_by_location_or_training_provider_page.continue.click
  end

  alias_method :and_i_visit_the_search_page, :when_i_visit_the_search_page
  alias_method :given_there_are_providers, :providers
end
