# frozen_string_literal: true

require 'rails_helper'

feature 'selecting full time or part time or full or part time', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_publish_courses_new_study_mode_page
  end

  scenario 'selecting full time' do
    when_i_select_a_study_mode(:full_time)
    and_i_click_continue
    then_i_am_met_with_the_schools_page(:full_time)

    when_i_click_back
    then_full_time_is_selected
  end

  scenario 'selecting part time' do
    when_i_select_a_study_mode(:part_time)
    and_i_click_continue
    then_i_am_met_with_the_schools_page(:part_time)

    when_i_click_back
    then_part_time_is_selected
  end

  scenario 'selecting full or part time' do
    when_i_select_a_study_mode(:full_time)
    and_i_select_a_study_mode(:part_time)
    and_i_click_continue
    then_i_am_met_with_the_schools_page(:full_time_or_part_time)

    when_i_click_back
    then_full_time_and_part_time_are_selected
  end

  scenario 'invalid entries' do
    and_i_click_continue
    then_i_am_met_with_errors
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_publish_courses_new_study_mode_page
    publish_courses_new_study_mode_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: study_mode_params)
  end

  def when_i_select_a_study_mode(study_mode)
    publish_courses_new_study_mode_page.study_mode_fields.send(study_mode).click
  end
  alias_method :and_i_select_a_study_mode, :when_i_select_a_study_mode

  def and_i_click_continue
    publish_courses_new_study_mode_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_schools_page(study_mode)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/schools/new#{selected_params(study_mode)}")
    expect(page).to have_content('Schools')
  end

  def then_i_am_met_with_errors
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select a study pattern').twice
  end

  def selected_params(study_mode)
    if study_mode == :full_time_or_part_time
      '?course%5Bage_range_in_years%5D=3_to_7&course%5Bis_send%5D=0&course%5Blevel%5D=primary&course%5Bstudy_mode%5D%5B%5D=full_time&course%5Bstudy_mode%5D%5B%5D=part_time&course%5Bsubjects_ids%5D%5B%5D=2'
    else
      "?course%5Bage_range_in_years%5D=3_to_7&course%5Bis_send%5D=0&course%5Blevel%5D=primary&course%5Bstudy_mode%5D%5B%5D=#{study_mode}&course%5Bsubjects_ids%5D%5B%5D=2"
    end
  end

  def when_i_click_back
    click_on 'Back'
  end

  def then_full_time_is_selected
    then_the_study_mode_is_selected(:full_time)
    then_the_study_mode_is_not_selected(:part_time)
  end

  def then_part_time_is_selected
    then_the_study_mode_is_selected(:part_time)
    then_the_study_mode_is_not_selected(:full_time)
  end

  def then_full_time_and_part_time_are_selected
    then_the_study_mode_is_selected(:full_time)
    then_the_study_mode_is_selected(:part_time)
  end

  def then_the_study_mode_is_selected(study_mode)
    expect(publish_courses_new_study_mode_page.study_mode_fields.send(study_mode).checked?).to be true
  end

  def then_the_study_mode_is_not_selected(study_mode)
    expect(publish_courses_new_study_mode_page.study_mode_fields.send(study_mode).checked?).to be false
  end
end
