# frozen_string_literal: true

require 'rails_helper'

feature 'editing applications open date', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    then_i_visit_the_applications_open_page
  end

  scenario 'choosing the default' do
    given_i_choose_as_soon_as_find_is_open
    when_i_click_update
    then_i_should_see_the_earliest_date_applications_can_open
  end

  scenario 'choosing a custom' do
    given_i_enter_a_custom_date
    when_i_click_update
    then_i_should_see_the_custom_date
  end

  def given_i_enter_a_custom_date
    find_field('Day').set('12')
    find_field('Month').set('12')
    find_field('Year').set(last_recruitment_cycle_year)
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def last_recruitment_cycle_year
    Settings.current_recruitment_cycle_year - 1
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists
  end

  def then_i_visit_the_applications_open_page
    visit applications_open_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, code: course.course_code
    )
  end

  def provider
    @current_user.providers.first
  end

  def course
    provider.courses.first
  end

  def given_i_choose_as_soon_as_find_is_open
    page.choose('As soon as the course is on Find - recommended')
  end

  def when_i_click_update
    page.click_link_or_button('Update applications open date')
  end

  def then_i_should_see_the_earliest_date_applications_can_open
    within("[data-qa='course__applications_open']") do
      expect(page).to have_text(course.recruitment_cycle.application_start_date.to_fs(:govuk_date))
    end
  end

  def then_i_should_see_the_custom_date
    within("[data-qa='course__applications_open']") do
      expect(page).to have_text("12 December #{last_recruitment_cycle_year}")
    end
  end
end
