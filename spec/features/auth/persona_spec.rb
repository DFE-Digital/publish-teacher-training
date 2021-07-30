# frozen_string_literal: true

require "rails_helper"

feature "sign in page" do
  before do
    allow(AuthenticationService).to receive(:mode).and_return("persona")
    sign_in_page.load
  end

  scenario "navigate to persona when mode is 'persona'" do
    expect(sign_in_page).to have_text("Use Personas to access an account.")
    expect(sign_in_page).to have_title("Sign in - Teacher Training API Admin")
    expect(sign_in_page).to have_link("Sign in using a Persona")
  end
end
