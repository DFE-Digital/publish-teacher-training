# frozen_string_literal: true

require "rails_helper"

feature "Authentication with Personas" do
  before do
    given_persona_based_authentication_is_active
  end

  scenario "Sign in with a persona" do
    when_i_go_to_sign_in
    then_i_am_given_the_option_to_sign_in_with_a_persona
  end

  scenario "Sign in to support" do
    when_i_go_to_support
    i_am_given_the_option_to_login_as_an_admin
    and_i_do_not_see_persona_related_text
  end

  def given_persona_based_authentication_is_active
    allow(AuthenticationService).to receive(:mode).and_return(:persona)
  end

  def when_i_go_to_sign_in
    sign_in_page.load
  end

  def when_i_go_to_support
    support_provider_index_page.load
  end

  def then_i_am_given_the_option_to_sign_in_with_a_persona
    expect(sign_in_page).to have_text("Use Personas to access an account.")
    expect(sign_in_page).to have_link("Sign in using a Persona")
  end

  def i_am_given_the_option_to_login_as_an_admin
    expect(sign_in_page).to have_button("Login as an Admin")
  end

  def and_i_do_not_see_persona_related_text
    expect(sign_in_page).not_to have_text("Use Personas to access an account.")
    expect(sign_in_page).not_to have_link("Sign in using a Persona")
  end
end
