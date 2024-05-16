# frozen_string_literal: true

require 'rails_helper'

feature 'Editing course study mode', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'I can update the course study mode to both full time and part time' do
    and_there_is_a_part_time_course_i_want_to_edit
    when_i_visit_the_course_study_mode_page
    then_i_see_part_time_selected

    and_i_choose_a_full_time_study_mode
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_study_mode_is_updated_to_full_or_part_time

    when_i_visit_the_course_study_mode_page
    then_i_see_both_part_time_and_full_time_selected
  end

  scenario 'I can change the course study mode from part time to full time' do
    and_there_is_a_part_time_course_i_want_to_edit
    when_i_visit_the_course_study_mode_page
    and_i_choose_a_full_time_study_mode
    and_i_uncheck_part_time_study_mode
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_study_mode_is_updated_to_full_time

    when_i_visit_the_course_study_mode_page
    then_i_see_full_time_selected
  end

  scenario 'updating with invalid data' do
    and_there_is_a_part_time_course_i_want_to_edit
    when_i_visit_the_course_study_mode_page
    and_i_uncheck_part_time_study_mode
    and_i_submit
    then_i_should_see_an_error_message
    and_nothing_is_selected
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_part_time_course_i_want_to_edit
    given_a_course_exists(study_mode: :part_time)
  end

  def and_there_is_a_course_with_no_study_mode
    given_a_course_exists
    @course.update_column(:study_mode, nil)
  end

  def when_i_visit_the_course_study_mode_page
    publish_course_study_mode_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def and_i_choose_a_full_time_study_mode
    publish_course_study_mode_edit_page.full_time.click
  end

  def and_i_uncheck_part_time_study_mode
    publish_course_study_mode_edit_page.part_time.click
  end

  def and_i_submit
    publish_course_study_mode_edit_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t('success.saved', value: 'Study pattern'))
  end

  def then_i_see_part_time_selected
    expect(publish_course_study_mode_edit_page.part_time.checked?).to be true
    expect(publish_course_study_mode_edit_page.full_time.checked?).to be false
  end

  def then_i_see_both_part_time_and_full_time_selected
    expect(publish_course_study_mode_edit_page.part_time.checked?).to be true
    expect(publish_course_study_mode_edit_page.full_time.checked?).to be true
  end

  def and_the_course_study_mode_is_updated_to_full_or_part_time
    expect(course.reload).to be_full_time_or_part_time
  end

  def and_the_course_study_mode_is_updated_to_full_time
    expect(course.reload).to be_full_time
  end

  def then_i_see_full_time_selected
    expect(publish_course_study_mode_edit_page.full_time.checked?).to be true
    expect(publish_course_study_mode_edit_page.part_time.checked?).to be false
  end

  def and_nothing_is_selected
    expect(publish_course_study_mode_edit_page.part_time.checked?).to be false
    expect(publish_course_study_mode_edit_page.full_time.checked?).to be false
  end

  def then_i_should_see_an_error_message
    expect(publish_course_study_mode_edit_page.error_messages)
      .to include('Select a study pattern')
  end

  def provider
    @current_user.providers.first
  end
end
