require "rails_helper"

feature "course searches" do
  include StubbedRequests::GeocoderHelper
  before do |test|
    stub_geocode if test.metadata[:geocode]
  end

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
    then_i_click_continue_on_the(courses_by_location_or_training_provider_page)
    and_i_am_on_the_age_groups_page
    then_the_correct_page_url_and_provider_query_params_are_present
    when_i_go_back
    the_provider_radio_button_is_selected
  end

  scenario "Candidate searches by location", :geocode do

    when_i_visit_the_search_page
    when_i_select_the_location_radio_button
    then_i_click_continue_on_the(courses_by_location_or_training_provider_page)
    then_i_should_see_a_missing_location_validation_error

    and_i_enter_a_location
    then_i_click_continue_on_the(courses_by_location_or_training_provider_page)
    and_i_am_on_the_age_groups_page
    then_the_correct_page_url_and_location_query_params_are_present
    when_i_go_back
    the_location_radio_button_is_selected

  end

  scenario "Candidate searches for secondary courses across England" do
    when_i_visit_the_search_page
    and_i_select_the_across_england_radio_button
    then_i_click_continue_on_the(courses_by_location_or_training_provider_page)
    and_i_am_on_the_age_groups_page
    then_the_correct_age_group_form_page_url_and_query_params_are_present

    when_i_choose_secondary
    then_i_click_continue_on_the(age_groups_page)
    then_i_should_see_the_subjects_form
    and_i_should_not_see_modern_languages
    then_the_correct_subjects_form_page_url_and_query_params_are_present
  end

  scenario "Candidate searches for primary courses across England" do
    when_i_visit_the_search_page
    and_i_select_the_across_england_radio_button
    then_i_click_continue_on_the(courses_by_location_or_training_provider_page)
    and_i_am_on_the_age_groups_page
    then_the_correct_age_group_form_page_url_and_query_params_are_present

    when_i_choose_primary
    then_i_click_continue_on_the(age_groups_page)
    then_i_should_see_the_primary_subjects_form
    then_the_correct_primary_subjects_form_page_url_and_query_params_are_present
  end

private

  def providers
    @providers ||= create_list(:provider, 3)
  end

  def when_i_go_back
    click_link("Back")
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

  def when_i_select_the_location_radio_button
    courses_by_location_or_training_provider_page.by_city_town_or_postcode_radio.choose
  end

  def and_i_select_the_across_england_radio_button
    courses_by_location_or_training_provider_page.across_england.choose
  end

  def and_i_select_the_provider
    options = providers.map { |provider| "#{provider.provider_name} (#{provider.provider_code})" } .sort

    expect(courses_by_location_or_training_provider_page.provider_options).to have_content options.join(" ")

    courses_by_location_or_training_provider_page.provider_options.select(options.sample)
  end

  def and_i_enter_a_location
    courses_by_location_or_training_provider_page.location.set("Yorkshire")
  end

  def then_i_click_continue_on_the(page)
    page.continue.click
  end

  def and_i_am_on_the_age_groups_page
    expect(age_groups_page).to be_displayed

    expect(age_groups_page).to have_primary
    expect(age_groups_page).to have_secondary
    expect(age_groups_page).to have_further_education

    expect(age_groups_page).to have_continue
  end

  def when_i_choose_primary
    age_groups_page.primary.choose
  end

  def when_i_choose_secondary
    age_groups_page.secondary.choose
  end

  def then_the_correct_page_url_and_provider_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/age-groups")
      expect(uri.query).to include("l=3&query=ACME+SCITT")
    end
  end

  def then_the_correct_page_url_and_location_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/age-groups")
      expect(uri.query).to eq("c=England&l=1&lat=51.4524877&lng=-0.1204749&loc=AA+Teamworks+W+Yorks+SCITT%2C+School+Street%2C+Greetland%2C+Halifax%2C+West+Yorkshire+HX4+8JB&lq=Yorkshire&rad=50&sortby=2")
    end
  end

  def then_the_correct_age_group_form_page_url_and_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/age-groups")
    end
  end

  def then_i_should_see_the_subjects_form
    expect(secondary_subjects_page).to have_content("Which secondary subjects do you want to teach?")
  end

  def then_i_should_see_the_primary_subjects_form
    expect(primary_subjects_page).to have_content("Which courses would you like to find?")
  end

  def and_i_should_not_see_modern_languages
    expect(secondary_subjects_page).not_to have_content("Modern Languages")
  end

  def then_the_correct_subjects_form_page_url_and_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/subjects")
      expect(uri.query).to eq("age_group=secondary&l=2")
    end
  end

  def then_the_correct_primary_subjects_form_page_url_and_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/subjects")
      expect(uri.query).to eq("age_group=primary&l=2")
    end
  end

  def then_i_should_see_a_missing_location_validation_error
    expect(page).to have_content('Enter a city, town or postcode')
  end

  def the_location_radio_button_is_selected
    expect(courses_by_location_or_training_provider_page.by_city_town_or_postcode_radio).to be_checked
  end

  def the_provider_radio_button_is_selected
    expect(courses_by_location_or_training_provider_page.by_school_uni_or_provider).to be_checked
  end

  alias_method :and_i_visit_the_search_page, :when_i_visit_the_search_page
  alias_method :given_there_are_providers, :providers
end
