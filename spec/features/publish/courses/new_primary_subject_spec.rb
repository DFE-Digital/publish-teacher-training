# frozen_string_literal: true

require 'rails_helper'

feature 'selecting a subject', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'selecting a subject' do
    when_i_visit_the_new_primary_course_subject_page
    when_i_select_a_primary_subject('Primary with English')
    and_i_click_continue
    then_i_am_met_with_the_age_range_page
  end

  scenario 'invalid entries' do
    when_i_visit_the_new_primary_course_subject_page
    and_i_click_continue
    then_i_am_met_with_errors
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_primary_course_subject_page
    publish_courses_new_subjects_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: primary_subject_params)
  end

  def when_i_select_a_primary_subject(subject_type)
    publish_courses_new_subjects_page.choose(subject_type)
  end

  def and_i_click_continue
    publish_courses_new_subjects_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_age_range_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new?#{params_with_subject}")
    expect(page).to have_content('Age range')
  end

  def then_i_am_met_with_errors
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select a subject')
  end

  def primary_subject
    find_or_create(:primary_subject, :primary_with_english)
  end

  def params_with_subject
    "course%5Bcampaign_name%5D=&course%5Bis_send%5D=0&course%5Blevel%5D=primary&course%5Bmaster_subject_id%5D=#{primary_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{primary_subject.id}"
  end
end
