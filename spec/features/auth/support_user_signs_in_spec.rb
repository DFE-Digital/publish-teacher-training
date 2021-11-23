# frozen_string_literal: true

require "rails_helper"

feature "Authentication" do
  scenario "Support user signs in" do
    given_i_am_a_support_user
    when_i_visit_the_support_interface
    then_i_am_expected_to_sign_in
    when_i_sign_in
    then_i_can_access_the_support_interface
  end

  def given_i_am_a_support_user
    @current_user = create(:user, :admin)
    user_exists_in_dfe_sign_in(user: @current_user)
  end

  def when_i_visit_the_support_interface
    visit support_path
  end

  def then_i_am_expected_to_sign_in
    expect(page).to have_content "Use DfE Sign-in to access your account"
  end

  def when_i_sign_in
    click_button "Sign in using DfE Sign-in"
  end

  def then_i_can_access_the_support_interface
    expect(page).to have_current_path support_providers_path
  end
end
