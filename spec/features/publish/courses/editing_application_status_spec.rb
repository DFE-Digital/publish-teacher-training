# frozen_string_literal: true

require 'rails_helper'

feature 'Editing course application status', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'opening a course' do
    and_there_is_a_closed_course_i_want_to_open
    when_i_visit_the_open_applications_confirm_page
    and_i_click_open_course
    then_i_should_see_the_success_message
    and_i_should_be_back_on_the_course_page
    and_the_course_is_open
  end

  scenario 'closing a course' do
    and_there_is_an_open_course_i_want_to_close
    when_i_visit_the_open_applications_confirm_page
    and_i_click_close_course
    then_i_should_see_the_closed_success_message
    and_i_should_be_back_on_the_course_page
    and_the_course_is_closed
  end

  def and_i_should_be_back_on_the_course_page
    expect(page).to have_current_path(publish_provider_recruitment_cycle_course_path(course.provider.provider_code, course.recruitment_cycle.year, course.course_code))
  end

  def and_the_course_is_open
    course.reload
    expect(course).to be_application_status_open
  end

  def and_the_course_is_closed
    course.reload
    expect(course).to be_application_status_closed
  end

  def then_i_should_see_the_success_message
    expect(page).to have_text('Course opened')
  end

  def then_i_should_see_the_closed_success_message
    expect(page).to have_text('Course closed')
  end

  def when_i_visit_the_open_applications_confirm_page
    visit application_status_publish_provider_recruitment_cycle_course_path(course.provider.provider_code, course.recruitment_cycle.year, course.course_code)
  end

  def and_i_click_open_course
    click_button 'Open course'
  end

  def and_i_click_close_course
    click_button 'Close course'
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_closed_course_i_want_to_open
    given_a_course_exists(name: 'Course', course_code: 'AAAA', application_status: 'closed')
  end

  def and_there_is_an_open_course_i_want_to_close
    given_a_course_exists(name: 'Course', course_code: 'AAAA', application_status: 'open')
  end
end
