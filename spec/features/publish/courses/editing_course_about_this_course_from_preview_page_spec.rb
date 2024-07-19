# frozen_string_literal: true

require 'rails_helper'

feature 'Editing about this course from the course preview page' do
  scenario 'I am redirected back to the preview page' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit

    when_i_visit_the_about_this_course_preview_page
    and_i_click_course_summary
    then_i_see_the_about_this_course_page

    when_i_add_a_course_summary
    and_i_submit_the_form
    then_i_am_on_the_preview_page
    and_i_see_the_change_i_made
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published, about_course: nil)])
  end

  def when_i_visit_the_about_this_course_preview_page
    visit preview_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def and_i_click_course_summary
    click_on 'Enter course details'
  end

  def then_i_see_the_about_this_course_page
    expect(page).to have_content 'About this course'
    expect(page).to have_current_path about_this_course_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    ), ignore_query: true
  end

  def when_i_add_a_course_summary
    fill_in 'About this course', with: 'La la la, about this course'
  end

  def and_i_submit_the_form
    click_on 'Update about this course'
  end

  def then_i_am_on_the_preview_page
    expect(page).to have_current_path preview_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    ), ignore_query: true
  end

  def and_i_see_the_change_i_made
    expect(page).to have_content 'La la la, about this course'
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
