# frozen_string_literal: true

require 'rails_helper'

feature 'Editing about this course section' do
  scenario 'adding valid data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_about_course_edit_page

    then_i_see_markdown_formatting_guidance

    when_i_enter_information_into_the_about_course_field
    and_i_submit_the_form
    then_about_course_data_has_changed

    when_i_visit_the_about_course_edit_page
    then_i_see_the_new_about_course_information
  end

  scenario 'navigating to course summary examples' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_about_course_edit_page
    and_i_click_the_link_to_view_examples
    then_i_am_redirected_to_the_expected_page
  end

  scenario 'entering invalid data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_about_course_edit_page
    and_i_delete_information_in_the_about_course_field
    and_i_submit_the_form
    then_i_see_an_error_message
  end

  private

  def then_i_see_markdown_formatting_guidance
    page.find('span', text: 'Help formatting your text')
    expect(page).to have_content 'How to format your text'
    expect(page).to have_content 'How to create a link'
    expect(page).to have_content 'How to create bullet points'
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_about_course_edit_page
    visit about_this_course_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def and_i_click_the_link_to_view_examples
    click_on 'View examples of great course summaries'
  end

  def then_i_am_redirected_to_the_expected_page
    expect(page).to have_content 'Course summary examples'
    expect(page).to have_current_path course_summary_examples_path, ignore_query: true
  end

  def and_i_submit_the_form
    click_on 'Update about this course'
  end

  def then_i_see_the_new_about_course_information
    expect(find_field('About this course').value).to eq 'Here is very useful information about this course'
  end

  def then_about_course_data_has_changed
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.about_course).to eq('Here is very useful information about this course')
    expect(page).to have_content 'Here is very useful information about this course'
  end

  def then_i_see_an_error_message
    expect(page).to have_content('Enter information about this course').twice
  end

  def and_i_delete_information_in_the_about_course_field
    fill_in 'About this course', with: ''
  end

  def when_i_enter_information_into_the_about_course_field
    fill_in 'About this course', with: 'Here is very useful information about this course'
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
