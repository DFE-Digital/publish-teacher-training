# frozen_string_literal: true

require "rails_helper"

feature "sign in page" do
  before do
    sign_in_page.load
  end

  scenario "navigate to sign in" do
    expect(sign_in_page).to have_text("Sign in")
    expect(sign_in_page).to have_title("Sign in - Teacher Training API Admin")
    expect(sign_in_page).to have_button("Sign in using DfE Sign-in")
  end
end
