require "rails_helper"

feature "switcher cycle" do
  before do
    Capybara.reset_sessions!
  end

  scenario "Navigate to /find/cycle" do
    when_i_visit_switcher_cycle_page
    then_i_should_see_the_page_title
    and_i_should_see_the_page_heading
  end

  scenario "Mid cycle and deadlines should be displayed" do
    when_i_visit_switcher_cycle_page
    and_i_choose_mid_cycle_and_deadlines_should_be_displayed_option
    then_i_click_on_update_button
    and_i_should_see_the_sucess_banner
    and_i_visit_results_page
    and_i_see_mid_cycle_and_deadlines_should_be_displayed_banner
  end

  scenario "Update to Apply 1 deadline has passed" do
    when_i_visit_switcher_cycle_page
    and_i_choose_apply_1_deadline_has_passed_option
    then_i_click_on_update_button
    and_i_should_see_the_sucess_banner
    and_i_visit_results_page
    and_i_see_apply_1_deadline_has_passed_banner
  end

  scenario "Update to Apply 2 deadline has passed" do
    when_i_visit_switcher_cycle_page
    and_i_choose_apply_2_deadline_has_passed_option
    then_i_click_on_update_button
    and_i_should_see_the_sucess_banner
    and_i_visit_results_page
    and_i_see_apply_2_deadline_has_passed_banner
  end

  scenario "Find has closed" do
    when_i_visit_switcher_cycle_page
    and_i_choose_find_has_closed_option
    then_i_click_on_update_button
    and_i_should_see_the_sucess_banner
    and_i_visit_results_page
    and_i_see_find_has_closed_banner
  end

  scenario "Find has reopened" do
    when_i_visit_switcher_cycle_page
    and_i_choose_find_has_reopened_option
    then_i_click_on_update_button
    and_i_should_see_the_sucess_banner
    and_i_visit_results_page
    and_i_see_find_has_reopened_banner
  end

  def when_i_visit_switcher_cycle_page
    visit "/find/cycles"
  end

  def then_i_should_see_the_page_title
    expect(page.title).to have_content "Recruitment cycles"
  end

  def and_i_should_see_the_page_heading
    expect(courses_by_location_or_training_provider_page.heading).to have_content "Recruitment cycles"
  end

  def and_i_choose_mid_cycle_and_deadlines_should_be_displayed_option
    page.choose("Mid cycle and deadlines should be displayed")
  end

  def and_i_choose_apply_1_deadline_has_passed_option
    page.choose("Apply 1 deadline has passed")
  end

  def and_i_choose_apply_2_deadline_has_passed_option
    page.choose("Apply 2 deadline has passed")
  end

  def and_i_choose_find_has_closed_option
    page.choose("Find has closed")
  end

  def and_i_choose_find_has_reopened_option
    page.choose("Find has reopened")
  end

  def then_i_click_on_update_button
    page.click_on("Update point in recruitment cycle")
  end

  def and_i_should_see_the_sucess_banner
    expect(page).to have_selector("h2", text: "Success")
  end

  def and_i_visit_results_page
    visit "/find/results"
  end

  def and_i_see_mid_cycle_and_deadlines_should_be_displayed_banner
    expect(page).to have_selector(".govuk-notification-banner__content", text: "Apply now to get on a course starting in the 2023 to 2024 academic year")
  end

  def and_i_see_apply_1_deadline_has_passed_banner
    expect(page).to have_selector(".govuk-notification-banner__content", text: "If you’re applying for the first time since applications opened in December 2022")
  end

  def and_i_see_apply_2_deadline_has_passed_banner
    expect(page).to have_selector(".govuk-notification-banner__content", text: "Courses are currently closed but you can get your application ready")
  end

  def and_i_see_find_has_closed_banner
    expect(page).should_not have_selector(".govuk-notification-banner__content")
  end

  def and_i_see_find_has_reopened_banner
    expect(page).should_not have_selector(".govuk-notification-banner__content")
  end

private

  def providers
    @providers ||= create_list(:provider, 3)
  end

  def when_i_visit_the_search_page
    courses_by_location_or_training_provider_page.load
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
