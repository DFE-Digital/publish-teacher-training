# frozen_string_literal: true

require "rails_helper"

feature "Editing a user" do
  before do
    given_i_am_authenticated(user: admin)
    and_a_user_exists
    when_i_visit_the_support_user_edit_page
  end

  scenario "successfully changing details" do
    and_i_fill_in_correct_details
    and_click_update
    i_am_taken_to_the_user_show_page
    with_a_success_message
  end

  scenario "incorrect details" do
    and_i_fill_in_with_blank_details
    and_click_update
    i_am_met_with_error_messages
  end

private

  def and_a_user_exists
    @user = create(:user, :with_provider)
  end

  def admin
    @admin ||= create(:user, :admin)
  end

  def when_i_visit_the_support_user_edit_page
    support_user_edit_page.load(id: @user.id)
  end

  def and_i_fill_in_correct_details
    support_user_edit_page.first_name_field.set("El")
    support_user_edit_page.last_name_field.set("Duderino")
    support_user_edit_page.email_field.set("the_dude_abides@education.gov.uk")
    support_user_edit_page.admin_checkbox.check
  end

  def and_i_fill_in_with_blank_details
    support_user_edit_page.first_name_field.set("")
    support_user_edit_page.last_name_field.set("")
    support_user_edit_page.email_field.set("")
  end

  def and_click_update
    support_user_edit_page.update.click
  end

  def i_am_met_with_error_messages
    expect(support_user_edit_page).to have_content("can't be blank")
  end

  def i_am_taken_to_the_user_show_page
    expect(support_user_show_page).to be_displayed
  end

  def with_a_success_message
    expect(support_user_show_page).to have_content("User successfully updated")
  end
end
