# frozen_string_literal: true

require "rails_helper"

feature "Opting into notifications" do
  before do
    given_i_am_authenticated_as_an_accredited_body_user
    when_i_visit_accredited_body_page
    and_i_click_on_notifications_link
    then_the_notification_page_is_displayed
    and_the_notifications_link_has_an_active_state
    then_neither_radio_button_is_selected
  end

  scenario "user sets notification preferences for the first time" do
    and_i_select_yes
    then_i_should_see_my_preferences_have_been_saved
    and_the_users_preference_is_set
  end

  scenario "user is shown an error if they submit without selection" do
    and_i_submit
    then_i_should_see_an_error_message
  end

  def given_i_am_authenticated_as_an_accredited_body_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_body)]))
  end

  def when_i_visit_accredited_body_page
    publish_providers_show_page.load(id: accrediting_provider.provider_code)
  end

  def and_i_click_on_notifications_link
    header_page.notifications_preference_link.click
  end

  def then_the_notification_page_is_displayed
    expect(notification_page).to be_displayed
  end

  def and_the_notifications_link_has_an_active_state
    expect(header_page).to have_active_notifications_preference_link
  end

  def then_neither_radio_button_is_selected
    expect(notification_page.opt_in_radio).not_to be_checked
    expect(notification_page.opt_out_radio).not_to be_checked
  end

  def and_i_select_yes
    notification_page.opt_in_radio.choose
    and_i_submit
  end

  def then_i_should_see_my_preferences_have_been_saved
    expect(publish_providers_show_page)
      .to have_content("Email notification preferences for #{@current_user.email} have been saved")
  end

  def and_the_users_preference_is_set
    expect(notification_preference.enabled?).to be(true)
  end

  def and_i_submit
    notification_page.submit.click
  end

  def then_i_should_see_an_error_message
    expect(course_study_mode_edit_page.error_messages).to include(
      "Please select one option",
    )
  end

  def accrediting_provider
    @current_user.providers.first
  end

  def notification_preference
    @notification_preference ||= UserNotificationPreferences.new(user_id: @current_user.id)
  end
end
