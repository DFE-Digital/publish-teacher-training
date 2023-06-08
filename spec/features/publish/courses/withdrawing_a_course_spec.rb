# frozen_string_literal: true

require 'rails_helper'

feature 'Withdrawing courses', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'i can withdraw a course' do
    and_there_is_a_course_i_want_to_withdraw
    when_i_visit_the_course_publish_courses_withdrawal_page
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_is_withdrawn
  end

  scenario 'course already withdrawn' do
    and_there_is_a_course_already_withdrawn
    when_i_visit_the_course_publish_courses_withdrawal_page
    then_i_am_redirected_to_the_courses_page
    and_i_see_the(already_withdrawn_message)
  end

  scenario 'attempting to withdraw a non published course' do
    and_there_is_a_draft_course
    when_i_visit_the_course_publish_courses_withdrawal_page
    then_i_am_redirected_to_the_courses_page
    and_i_see_the(course_should_be_deleted_message)
  end

  scenario 'i can close the course instead' do
    and_there_is_a_course_i_want_to_withdraw
    when_i_visit_the_course_publish_courses_withdrawal_page
    and_i_click_link('close the course instead')
    then_i_should_be_on_the_close_confirmation_page
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_withdraw(application_status: :open)
    given_a_course_exists(application_status:, enrichments: [build(:course_enrichment, :published)])
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  def and_there_is_a_course_already_withdrawn
    given_a_course_exists(enrichments: [build(:course_enrichment, :withdrawn)])
  end

  def and_there_is_a_draft_course
    given_a_course_exists(enrichments: [build(:course_enrichment, :initial_draft)])
  end

  def when_i_visit_the_course_publish_courses_withdrawal_page
    publish_courses_withdrawal_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def and_i_submit
    publish_courses_withdrawal_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(withdrawn_message)
  end

  def and_the_course_is_withdrawn
    enrichment = course.reload.enrichments.max_by(&:created_at)

    expect(enrichment).to be_withdrawn
  end

  def then_i_am_redirected_to_the_courses_page
    expect(publish_provider_courses_index_page).to be_displayed
  end

  def and_i_see_the(message)
    expect(page).to have_content(message)
  end

  def provider
    @current_user.providers.first
  end

  def withdrawn_message
    "#{course_name_and_code} has been withdrawn"
  end

  def already_withdrawn_message
    "#{course_name_and_code} has already been withdrawn"
  end

  def course_should_be_deleted_message
    'Courses that have not been published should be deleted not withdrawn'
  end

  def course_name_and_code
    "#{course.name} (#{course.course_code})"
  end

  def then_i_should_be_on_the_close_confirmation_page
    expect(page.title).to have_content('Are you sure you want to close this course?')

    expect(page.current_url).to end_with("publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/application_status?goto=withdraw")
  end

  alias_method :and_i_click_link, :click_link
end
