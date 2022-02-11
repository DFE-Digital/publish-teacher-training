# frozen_string_literal: true

require "rails_helper"

feature "Authentication" do
  scenario "Provider user signs in" do
    given_i_am_a_provider_user
    when_i_visit_the_root_path
    then_i_am_expected_to_sign_in
    when_i_sign_in
    then_i_can_access_the_publish
    and_i_cannot_access_the_support_interface
  end

  scenario "users are shown the right signin content when arriving from Old Publish" do
    given_i_arrive_from_old_publish
    and_i_am_a_provider_user
    then_i_see_the_signin_page
    and_i_am_shown_the_right_content
  end

  def given_i_arrive_from_old_publish
    allow_any_instance_of(ActionDispatch::Request).to receive(:referer).and_return(Settings.publish_url)
    disable_features(:send_request_data_to_bigquery)
    enable_features(:display_migration_signin)
  end

  def given_i_am_a_provider_user
    @current_user = create(:user)
    user_exists_in_dfe_sign_in(user: @current_user)
  end
  alias_method :and_i_am_a_provider_user, :given_i_am_a_provider_user

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
    expect(page).to have_content "User is not an admin"
    expect(page).to have_current_path sign_in_path
  end

  def then_i_see_the_signin_page
    sign_in_page.load
  end

  def and_i_am_shown_the_right_content
    expect(sign_in_page).to have_text("Sign in to continue")
    expect(sign_in_page).to have_button("Sign in")
  end
end
