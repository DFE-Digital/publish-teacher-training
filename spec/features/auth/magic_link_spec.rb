# frozen_string_literal: true

require "rails_helper"

feature "Authentication with magic links" do
  include ActiveJob::TestHelper

  before do
    given_magic_link_auth_is_enabled
  end

  after do
    disable_magic_link_auth
  end

  scenario "Receiving a magic link" do
    and_a_user_exists
    when_i_go_to_sign_in
    then_i_am_taken_to_the_magic_link_page
    and_i_am_given_the_option_to_sign_in_with_a_magic_link
    when_i_enter_a_valid_email
    then_a_magic_link_is_sent
    and_i_am_taken_to_the_confirmation_page
  end

  scenario "Signing in with a valid magic link" do
    given_a_magic_link_token_is_available
    when_i_visit_the_magic_link_with(@user.magic_link_token)
    then_i_am_signed_in
  end

  scenario "Signing in with an invalid magic link" do
    given_a_magic_link_token_is_available
    when_i_visit_the_magic_link_with("invalid_token")
    then_i_am_not_signed_in
    and_i_am_shown_the(invalid_token_message)
  end

  scenario "Signing in with an expired magic link" do
    given_a_magic_link_token_is_available_but_has_expired
    when_i_visit_the_magic_link_with(@user.magic_link_token)
    then_i_am_not_signed_in
    and_i_am_shown_the(expired_token_message)
  end

  scenario "Entering invalid email" do
    when_i_go_to_sign_in
    then_i_am_taken_to_the_magic_link_page
    and_i_am_given_the_option_to_sign_in_with_a_magic_link
    when_i_enter_an_invalid_email
    then_i_am_shown_an_error_message
  end

  def given_magic_link_auth_is_enabled
    allow(AuthenticationService).to receive(:mode).and_return("magic_link")
    Rails.application.reload_routes!
  end

  def given_a_magic_link_token_is_available
    @user = create(:user, :with_magic_link_token)
  end

  def given_a_magic_link_token_is_available_but_has_expired
    @user = create(:user, :with_magic_link_token, magic_link_token_sent_at: 1.day.ago)
  end

  def when_i_visit_the_magic_link_with(token)
    visit signin_with_magic_link_path(email: @user.email, token:)
  end

  def then_i_am_signed_in
    expect(page).to have_content("Sign out")
  end

  def then_i_am_not_signed_in
    expect(page).to have_content("Sign in")
  end

  def and_a_user_exists
    @user = create(:user, email: "some@email.com")
  end

  def when_i_go_to_sign_in
    sign_in_page.load
  end

  def then_i_am_taken_to_the_magic_link_page
    expect(magic_link_page).to be_displayed
  end

  def when_i_enter_a_valid_email
    magic_link_page.email_field.set(@user.email)
  end

  def then_a_magic_link_is_sent
    expect do
      magic_link_page.submit.click
    end.to have_enqueued_job.on_queue("mailers").exactly(:once)
  end

  def when_i_enter_an_invalid_email
    magic_link_page.email_field.set("some random string")
    magic_link_page.submit.click
  end

  def then_i_am_shown_an_error_message
    expect(magic_link_page).to have_text("Enter a valid email address")
  end

  def and_i_am_taken_to_the_confirmation_page
    expect(magic_link_confirmation_page).to be_displayed
  end

  def and_i_am_given_the_option_to_sign_in_with_a_magic_link
    expect(magic_link_page).to have_text("DfE Sign-in is experiencing problems. You need to sign in using your email address.")
    expect(magic_link_page).to have_email_field
  end

  def and_i_am_shown_the(message)
    expect(page).to have_text(message)
  end

  def invalid_token_message
    I18n.t("publish_authentication.magic_link.invalid_token")
  end

  def expired_token_message
    I18n.t("publish_authentication.magic_link.expired")
  end

  def disable_magic_link_auth
    allow(AuthenticationService).to receive(:mode).and_return(nil)
    Rails.application.reload_routes!
  end
end
