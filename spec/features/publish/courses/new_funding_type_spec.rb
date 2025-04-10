# frozen_string_literal: true

require "rails_helper"

feature "selecting funding type", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_publish_courses_new_funding_type_page
  end

  scenario "selecting fee paying" do
    when_i_select_funding_type(:fee)
    and_i_click_continue
    and_i_click_back
    and_fee_is_is_still_selected
    and_i_click_continue
    then_i_am_met_with_the_full_or_part_time_page(:fee)
  end

  scenario "selecting salaried" do
    when_i_select_funding_type(:salary)
    and_i_click_continue
    and_i_click_back
    and_salary_is_is_still_selected
    and_i_click_continue
    then_i_am_met_with_the_full_or_part_time_page(:salary)
  end

  scenario "selecting apprenticeship" do
    when_i_select_funding_type(:apprenticeship)
    and_i_click_continue
    and_i_click_back
    and_apprenticeship_is_is_still_selected
    and_i_click_continue
    then_i_am_met_with_the_full_or_part_time_page(:apprenticeship)
  end

  scenario "invalid entries" do
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_publish_courses_new_funding_type_page
    publish_courses_new_funding_type_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: funding_type_params)
  end

  def when_i_select_funding_type(funding_type)
    publish_courses_new_funding_type_page.funding_type_fields.send(funding_type).click
  end

  def and_i_click_continue
    publish_courses_new_funding_type_page.continue.click
  end

  def and_i_click_back
    click_on "Back"
  end

  def and_fee_is_is_still_selected
    expect(page).to have_checked_field("Fee - no salary")
  end

  def and_salary_is_is_still_selected
    expect(page).to have_checked_field("Salary")
  end

  def and_apprenticeship_is_is_still_selected
    expect(page).to have_checked_field("Teaching apprenticeship - with salary")
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_full_or_part_time_page(funding_type)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/full-part-time/new#{selected_params(funding_type)}")
    expect(page).to have_content("Study pattern")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a funding type")
  end

  def selected_params(funding_type)
    "?course%5Bage_range_in_years%5D=3_to_7&course%5Bfunding%5D=#{funding_type}&course%5Bis_send%5D=0&course%5Blevel%5D=primary&course%5Bsubjects_ids%5D%5B%5D=2"
  end
end
