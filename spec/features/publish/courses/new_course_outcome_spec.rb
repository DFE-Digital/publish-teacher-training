# frozen_string_literal: true

require "rails_helper"

feature "selecting a course outcome" do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_publish_courses_new_outcome_page
  end

  scenario "selecting qts" do
    when_i_select_an_outcome(:qts)
    and_i_click_continue
    then_i_am_met_with_the_funding_type_page(:qts)
  end

  scenario "selecting pgce with qts" do
    when_i_select_an_outcome(:pgce_with_qts)
    and_i_click_continue
    then_i_am_met_with_the_funding_type_page(:pgce_with_qts)
  end

  scenario "selecting pgde with qts" do
    when_i_select_an_outcome(:pgde_with_qts)
    and_i_click_continue
    then_i_am_met_with_the_funding_type_page(:pgde_with_qts)
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

  def when_i_visit_the_publish_courses_new_outcome_page
    publish_courses_new_outcome_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Find::CycleTimetable.current_year, query: outcome_params)
  end

  def when_i_select_an_outcome(outcome)
    publish_courses_new_outcome_page.qualification_fields.send(outcome).click
  end

  def and_i_click_continue
    publish_courses_new_outcome_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_funding_type_page(outcome)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Find::CycleTimetable.current_year}/courses/funding-type/new#{selected_params(outcome)}")
    expect(page).to have_content("Funding type")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a qualification")
  end

  def selected_params(outcome)
    "?course%5Bage_range_in_years%5D=3_to_7&course%5Bis_send%5D=0&course%5Blevel%5D=primary&course%5Bqualification%5D=#{outcome}&course%5Bsubjects_ids%5D%5B%5D=2"
  end
end
