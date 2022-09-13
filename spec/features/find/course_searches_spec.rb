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
    then_i_click_continue_on_the(courses_by_location_or_training_provider_page)
    and_i_am_on_the_age_groups_page
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
    and_i_should_not_see_hidden_subjects
    then_the_correct_subjects_form_page_url_and_query_params_are_present
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

  def and_i_select_the_across_england_radio_button
    courses_by_location_or_training_provider_page.across_england.choose
  end

  def and_i_select_the_provider
    options = providers.map { |provider| "#{provider.provider_name} (#{provider.provider_code})" } .sort

    expect(courses_by_location_or_training_provider_page.provider_options).to have_content options.join(" ")

    courses_by_location_or_training_provider_page.provider_options.select(options.sample)
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

  def when_i_choose_secondary
    age_groups_page.secondary.choose
  end

  def then_the_correct_age_group_form_page_url_and_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/age-groups")
    end
  end

  def then_i_should_see_the_subjects_form
    expect(secondary_subjects_page).to have_content("Which secondary subjects do you want to teach?")
  end

  def and_i_should_not_see_hidden_subjects
    expect(secondary_subjects_page).not_to have_content("Ancient Hebrew")
    expect(secondary_subjects_page).not_to have_content("Philosophy")
    expect(secondary_subjects_page).not_to have_content("Modern Languages")
  end

  def then_the_correct_subjects_form_page_url_and_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/subjects")
      expect(uri.query).to eq("age_group=secondary")
    end
  end

  alias_method :and_i_visit_the_search_page, :when_i_visit_the_search_page
  alias_method :given_there_are_providers, :providers
end
