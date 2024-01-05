# frozen_string_literal: true

require 'rails_helper'

feature 'Reverting a withdrawal' do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider_with_a_withdrawn_course
  end

  scenario 'Reverting a withdrawn course' do
    when_i_navigate_to_the_withdrawn_course
    and_i_click_revert_withdrawal
    and_i_confirm
    and_i_see_the_success_message
    then_i_should_see_the_published_and_closed_course
    and_i_should_no_longer_see_the_revert_withdrawal_link
  end

  def and_i_should_no_longer_see_the_revert_withdrawal_link
    expect(page).to have_no_link('Revert withdrawal')
  end

  def then_i_should_see_the_published_and_closed_course
    expect(page).to have_css('.govuk-tag.govuk-tag--purple', text: 'Closed')
  end

  def and_i_see_the_success_message
    expect(page).to have_css('.govuk-notification-banner__heading', text: 'Course status successfully updated')
  end

  def and_i_confirm
    click_link_or_button 'Revert withdrawal'
  end

  def when_i_navigate_to_the_withdrawn_course
    visit edit_support_recruitment_cycle_provider_course_path(provider_id: @provider.id, id: @course.id, recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def and_i_click_revert_withdrawal
    click_link_or_button 'Revert withdrawal'
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def and_there_is_a_provider_with_a_withdrawn_course
    @provider ||= create(:provider, courses: [build(:course, :withdrawn)])
    @course ||= @provider.courses.first
  end
end
