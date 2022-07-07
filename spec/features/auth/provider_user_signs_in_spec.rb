# frozen_string_literal: true

require "rails_helper"

feature "Authentication" do
  scenario "Provider user signs in", { can_edit_current_and_next_cycles: false } do
    given_i_am_a_provider_user
    when_i_visit_the_root_path
    then_i_am_expected_to_sign_in
    when_i_sign_in
    then_i_can_access_the_publish
    and_i_cannot_access_the_support_interface
  end

  def given_i_am_a_provider_user
    @current_user = create(:user)
    user_exists_in_dfe_sign_in(user: @current_user)
  end

  def when_i_visit_the_root_path
    visit publish_root_path
  end

  def then_i_am_expected_to_sign_in
    expect(page).to have_content "Use DfE Sign-in to access your account"
  end

  def when_i_sign_in
    click_button "Sign in using DfE Sign-in"
  end

  def then_i_can_access_the_publish
    expect(page).to have_current_path publish_root_path
    expect(page).to have_content "Publish teacher training"
  end

  def and_i_cannot_access_the_support_interface
    visit support_providers_path
    expect(page).to have_current_path support_providers_path
    expect(page.status_code).to eq(403)
    expect(page.find("h1")).to have_content("You are not permitted to see this page")
  end
end
