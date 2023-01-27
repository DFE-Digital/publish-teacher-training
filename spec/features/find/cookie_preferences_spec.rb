# frozen_string_literal: true

require 'rails_helper'

feature 'Updating cookie preferences' do
  scenario 'i can update my cookie preferences' do
    given_i_am_on_the_cookie_preferences_page
    and_i_can_see_the_heading
    and_i_can_see_the_the_use_of_cookies_for_service
    when_i_give_consent_and_submit
    then_i_should_see_a_confirmation_message
  end

  scenario 'i cannot update without selecting a preference' do
    given_i_am_on_the_cookie_preferences_page
    when_i_submit
    then_i_should_see_an_error_message
  end

  def given_i_am_on_the_cookie_preferences_page
    cookie_preferences_page.load
  end

  def when_i_give_consent_and_submit
    cookie_preferences_page.yes_option.choose
    when_i_submit
  end

  def then_i_should_see_a_confirmation_message
    expect(cookie_preferences_page).to have_content('Your cookie preferences have been updated')
  end

  def when_i_submit
    cookie_preferences_page.submit.click
  end

  def then_i_should_see_an_error_message
    expect(cookie_preferences_page.error_messages).to include(
      'Select yes if you want to accept Google Analytics cookies'
    )
  end

  def and_i_can_see_the_heading
    expect(cookie_preferences_page.heading).to have_content('Cookies')
  end

  def and_i_can_see_the_the_use_of_cookies_for_service
    expect(cookie_preferences_page).to have_content("We use cookies to make #{service_name} work and collect information about how you use our service.")
  end

  def service_name
    'Find postgraduate teacher training (Find)'
  end

  def cookie_preferences_page
    @cookie_preferences_page ||= PageObjects::Find::CookiePreferences.new
  end
end
