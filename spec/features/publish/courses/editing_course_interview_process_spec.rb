# frozen_string_literal: true

require 'rails_helper'

feature 'Editing interview process section' do
  scenario 'adding valid data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_interview_process_edit_page
    and_i_enter_information_into_the_interview_process_field
    and_i_submit_the_form
    then_interview_process_data_has_changed

    when_i_visit_the_interview_process_edit_page
    then_i_see_the_new_interview_process_information
  end

  scenario 'entering invalid data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_interview_process_edit_page
    and_i_enter_invalid_data
    and_i_submit_the_form
    then_i_see_an_error_message
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_interview_process_edit_page
    visit interview_process_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def and_i_submit_the_form
    click_on 'Update interview process'
  end

  def then_i_see_the_new_interview_process_information
    expect(find_field('Interview process').value).to eq 'Here is very useful information interview process'
  end

  def then_interview_process_data_has_changed
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.interview_process).to eq('Here is very useful information interview process')
    expect(page).to have_content 'Here is very useful information interview process'
  end

  def then_i_see_an_error_message
    expect(page).to have_content('Reduce the word count for interview process').twice
  end

  def and_i_enter_invalid_data
    fill_in 'Interview process', with: Faker::Lorem.sentence(word_count: 251)
  end

  def and_i_enter_information_into_the_interview_process_field
    fill_in 'Interview process (optional)', with: 'Here is very useful information interview process'
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
