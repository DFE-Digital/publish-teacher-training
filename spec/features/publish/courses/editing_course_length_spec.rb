# frozen_string_literal: true

require 'rails_helper'

feature 'Editing course length' do
  scenario 'I enter invalid data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_without_a_length_i_want_to_edit
    when_i_visit_the_course_length_edit_page
    and_i_submit_the_form
    then_i_an_error_message
  end

  scenario 'I update the course length to a standard length (eg Up to two years)' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_1_year_course_i_want_to_edit
    when_i_visit_the_course_length_edit_page
    then_i_see_one_year_selected

    when_i_update_the_length_to_2_years
    and_i_submit_the_form
    then_i_see_a_success_message
    and_the_course_length_is_two_years

    when_i_visit_the_course_length_edit_page
    then_i_see_two_years_selected
  end

  scenario 'I update the course length with a custom length' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_5_year_course_i_want_to_edit
    when_i_visit_the_course_length_edit_page
    then_i_see_the_custom_length_of_5_years

    when_i_update_the_length_to_a_custom_length
    and_i_submit_the_form
    then_i_see_a_success_message
    and_the_course_length_is_the_custom_length

    when_i_visit_the_course_length_edit_page
    then_i_see_the_custom_length
  end

  scenario 'I try to edit course that should not be edited' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_an_uneditable_course
    when_i_visit_the_course_length_edit_page
    then_i_am_redirected_to_the_summary_page
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_without_a_length_i_want_to_edit
    and_there_is_a_course_i_want_to_edit(nil)
  end

  def and_there_is_a_1_year_course_i_want_to_edit
    and_there_is_a_course_i_want_to_edit('OneYear')
  end

  def and_there_is_a_5_year_course_i_want_to_edit
    and_there_is_a_course_i_want_to_edit('5 years')
  end

  def and_there_is_an_uneditable_course
    given_a_course_exists(program_type: 'TDA')
  end

  def and_there_is_a_course_i_want_to_edit(course_length)
    given_a_course_exists(enrichments: [build(:course_enrichment, :published, course_length:)])
  end

  def then_i_am_redirected_to_the_summary_page
    expect(page).to have_current_path publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      code: course.course_code
    ), ignore_query: true
  end

  def when_i_visit_the_course_length_edit_page
    visit length_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def when_i_update_the_length_to_2_years
    choose 'Up to 2 years'
  end

  def when_i_update_the_length_to_a_custom_length
    fill_in 'Course length', with: 'Three years'
  end

  def then_i_see_two_years_selected
    expect(find_field('Up to 2 years')).to be_checked
  end

  def then_i_see_one_year_selected
    expect(find_field('1 year')).to be_checked
  end

  def then_i_see_the_custom_length_of_5_years
    expect(find_field('Other')).to be_checked
    expect(find_field('Course length').value).to eq '5 years'
  end

  def then_i_see_the_custom_length
    expect(find_field('Other')).to be_checked
    expect(find_field('Course length').value).to eq 'Three years'
  end

  def and_i_submit_the_form
    click_on 'Update course length'
  end

  def then_i_an_error_message
    expect(page).to have_content('Enter a course length').twice
  end

  def then_i_see_a_success_message
    expect(page).to have_content('Course length updated')
  end

  def and_the_course_length_is_two_years
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.course_length).to eq 'TwoYears'
    expect(page).to have_content 'Up to 2 years'
  end

  def and_the_course_length_is_the_custom_length
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.course_length).to eq('Three years')
    expect(page).to have_content 'Three years'
  end

  def provider
    @current_user.providers.first
  end
end
