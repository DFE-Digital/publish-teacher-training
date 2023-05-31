# frozen_string_literal: true

require 'rails_helper'

feature 'Editing course application status', { can_edit_current_and_next_cycles: false } do
  before do
    given_the_open_and_closed_course_flow_feature_is_active
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'opening a course' do
    and_there_is_a_closed_course_i_want_to_open
    when_i_visit_the_course_show_page
    and_i_click_open_course_link
    then_i_am_on_the_application_status_confirm_page
    and_i_click_open_course
    then_i_should_see_the_success_message
    and_i_should_be_back_on_the_course_page
    and_the_course_is_open
  end

  scenario 'closing a course' do
    and_there_is_an_open_course_i_want_to_close
    when_i_visit_the_course_show_page
    and_i_click_close_course_link
    then_i_am_on_the_application_status_confirm_page
    and_i_click_close_course
    then_i_should_see_the_closed_success_message
    and_i_should_be_back_on_the_course_page
    and_the_course_is_closed
  end

  def when_i_visit_the_course_show_page
    visit publish_provider_recruitment_cycle_course_path(course.provider.provider_code, course.recruitment_cycle.year, course.course_code)
  end

  def and_i_click_open_course_link
    click_link 'Open course'
  end

  def and_i_click_close_course_link
    click_link 'Close course'
  end

  def and_i_should_be_back_on_the_course_page
    expect(page).to have_current_path(publish_provider_recruitment_cycle_course_path(course.provider.provider_code, course.recruitment_cycle.year, course.course_code))
  end

  def and_the_course_is_open
    course.reload
    expect(course).to be_application_status_open
    expect(page).to have_css('.govuk-tag--turquoise')
  end

  def and_the_course_is_closed
    course.reload
    expect(course).to be_application_status_closed
    expect(page).to have_css('.govuk-tag--purple')
  end

  def then_i_should_see_the_success_message
    expect(page).to have_text('Course opened')
  end

  def then_i_should_see_the_closed_success_message
    expect(page).to have_text('Course closed')
  end

  def then_i_am_on_the_application_status_confirm_page
    expect(page).to have_current_path("/publish/organisations/#{course.provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/application_status")
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

  def given_the_open_and_closed_course_flow_feature_is_active
    allow(Settings.features).to receive(:open_and_closed_course_flow).and_return(true)
  end

  def and_there_is_a_closed_course_i_want_to_open
    given_a_course_exists(:published, application_status: 'closed')
    given_a_site_exists(:findable)
  end

  def and_there_is_an_open_course_i_want_to_close
    given_a_course_exists(:published, application_status: 'open')
    given_a_site_exists(:findable)
  end
end
