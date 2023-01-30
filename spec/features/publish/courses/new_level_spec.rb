# frozen_string_literal: true

require 'rails_helper'

feature 'selecting a level', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_i_visit_the_new_course_level_page
  end

  scenario 'selecting primary' do
    given_i_select_primary_level
    and_i_click_continue
    then_i_am_met_with_the_primary_subjects_page
  end

  scenario 'secondary level flow' do
    given_i_select_secondary_level
    and_i_click_continue
    then_i_am_met_with_the_secondary_subjects_page
  end

  scenario 'further education level flow' do
    given_i_select_further_education_level
    and_i_click_continue
    then_i_am_met_with_the_course_outcome_page
  end

  scenario 'with SEND checked' do
    [given_i_select_further_education_level, given_i_select_secondary_level, given_i_select_primary_level].sample
    and_i_check_is_send
    and_i_click_continue
    then_with_send_is_in_params
  end

  scenario 'invalid entries' do
    given_i_select_nothing
    and_i_click_continue
    then_i_am_met_with_errors
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_i_visit_the_new_course_level_page
    publish_courses_new_level_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def given_i_select_primary_level
    publish_courses_new_level_page.level_fields.primary.click
  end

  def given_i_select_secondary_level
    publish_courses_new_level_page.level_fields.secondary.click
  end

  def given_i_select_further_education_level
    publish_courses_new_level_page.level_fields.further_education.click
  end

  def given_i_select_nothing; end

  def and_i_click_continue
    publish_courses_new_level_page.continue.click
  end

  def and_i_check_is_send
    publish_courses_new_level_page.send_specialism_checkbox.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_primary_subjects_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/subjects/new#{primary_level_selected_params}")
    expect(page).to have_content('Subject')
  end

  def then_i_am_met_with_the_secondary_subjects_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/subjects/new#{secondary_level_selected_params}")
    expect(page).to have_content('Subject')
  end

  def then_i_am_met_with_the_course_outcome_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/outcome/new#{further_education_level_selected_params}")
    expect(page).to have_content('Pick a course outcome')
  end

  def then_i_am_met_with_errors
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select a course level')
  end

  def then_with_send_is_in_params
    expect(page.current_url).to match(/is_send%5D=1/)
  end

  def primary_level_selected_params
    '?course%5Bis_send%5D=0&course%5Blevel%5D=primary'
  end

  def secondary_level_selected_params
    '?course%5Bis_send%5D=0&course%5Blevel%5D=secondary'
  end

  def further_education_level_selected_params
    '?course%5Bis_send%5D=0&course%5Blevel%5D=further_education'
  end
end
