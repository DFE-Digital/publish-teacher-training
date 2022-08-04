# frozen_string_literal: true

require "rails_helper"

feature "Updating cookie preferences" do
  scenario "i can update my cookie preferences" do
    when_i_visit_the_cookie_preferences_page
    and_i_give_consent_and_submit
    then_i_should_see_a_confirmation_message
  end

  scenario "i cannot update without selecting a preference" do
    when_i_visit_the_cookie_preferences_page
    and_i_submit
    then_i_should_see_an_error_message
  end

  def when_i_visit_the_cookie_preferences_page
    cookie_preferences_page.load
  end

  def and_i_give_consent_and_submit
    cookie_preferences_page.yes_option.choose
    and_i_submit
  end

  def then_i_should_see_a_confirmation_message
    expect(cookie_preferences_page).to have_text("Your cookie preferences have been updated")
  end

  def and_i_submit
    cookie_preferences_page.submit.click
  end

  def then_i_should_see_an_error_message
    expect(cookie_preferences_page.error_messages).to include(
      "Select yes if you want to accept Google Analytics cookies",
    )
  end
end
