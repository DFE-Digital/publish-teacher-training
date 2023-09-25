# frozen_string_literal: true

require 'rails_helper'

feature 'editing course start date', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    then_i_visit_the_start_date_page
  end

  scenario 'choosing december' do
    given_i_choose_december
    when_i_click_update
    then_i_should_see_the_december_start_date
    and_i_should_see_the_success_flash_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def current_recruitment_cycle_year
    Settings.current_recruitment_cycle_year
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists
  end

  def then_i_visit_the_start_date_page
    visit start_date_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, code: course.course_code
    )
  end

  def provider
    @current_user.providers.first
  end

  def course
    provider.courses.first
  end

  def given_i_choose_december
    page.choose("December #{current_recruitment_cycle_year}")
  end

  def when_i_click_update
    page.click_button('Update course start date')
  end

  def then_i_should_see_the_december_start_date
    within("[data-qa='course__start_date']") do
      expect(page).to have_text("December #{current_recruitment_cycle_year}")
    end
  end

  def and_i_should_see_the_success_flash_message
    expect(page).to have_css('.govuk-notification-banner__heading', text: 'Course start date updated')
  end
end
