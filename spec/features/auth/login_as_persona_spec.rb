# frozen_string_literal: true

require "rails_helper"

feature "Login as Persona" do
  scenario "Unauthenticated user logs in as Persona" do
    given_persona_based_authentication_is_active
    and_i_am_on_the_personas_page
  end

  def and_i_am_on_the_personas_page
    # binding.pry
    persona_index_page.load
  end

  def given_persona_based_authentication_is_active
    allow(AuthenticationService).to receive(:mode).and_return("persona")
  end
end