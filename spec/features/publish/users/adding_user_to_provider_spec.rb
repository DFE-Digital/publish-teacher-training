# frozen_string_literal: true

require "rails_helper"

feature "Adding user to organisation as a provider user", { can_edit_current_and_next_cycles: false } do
  before do
    allow(Settings.features).to receive(:user_management).and_return(true)
    given_i_am_authenticated_as_a_provider_user
  end

  describe "Adding user to organisation" do
    scenario "With valid details" do
      given_i_visit_the_users_index_page
      and_the_user_i_want_to_add_has_not_already_been_added
      and_i_click_add_user
      and_i_fill_in_first_name
      and_i_fill_in_last_name
      and_i_fill_in_email
      and_i_continue
      then_i_should_be_on_the_check_page
      and_the_user_should_not_be_in_the_database

      when_i_click_change_first_name
      and_i_enter_a_new_first_name
      and_i_continue
      and_i_click_add_user

      then_i_should_see_the_users_name_listed
      and_i_should_see_the_users_email_listed
      and_the_user_should_be_added_to_the_database
    end

    scenario "With invalid details" do
      given_i_visit_the_users_new_page
      and_i_continue

      then_it_should_display_the_correct_error_messages
    end
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider, provider_name: "Batman's Chocolate School")
    @user = create(:user, providers: [@provider])
    given_i_am_authenticated(user: @user)
  end

  def given_i_visit_the_users_index_page
    users_index_page.load(provider_code: @provider.provider_code)
  end

  def and_the_user_i_want_to_add_has_not_already_been_added
    expect(users_index_page).not_to have_text("willy.wonka@bat_school.com")
  end

  def and_i_click_add_user
    provider_users_index_page.add_user.click
  end

  def and_i_fill_in_first_name
    users_new_page.first_name.set("Silly")
  end

  def and_i_fill_in_last_name
    users_new_page.last_name.set("Wonka")
  end

  def and_i_fill_in_email
    users_new_page.email.set("willy.wonka@bat_school.com")
  end

  def and_i_continue
    users_new_page.submit.click
  end

  def then_i_should_be_on_the_check_page
    expect(users_check_page).to be_displayed(provider_code: @provider.provider_code)
  end

  def and_the_user_should_not_be_in_the_database
    expect(Provider.find_by(provider_name: "Batman's Chocolate School").users.where(email: "willy.wonka@bat_school.com").blank?).to be(true)
  end

  def when_i_click_change_first_name
    users_check_page.change_first_name.click
  end

  def and_i_enter_a_new_first_name
    users_new_page.first_name.set("Willy")
  end

  def and_i_continue
    users_new_page.submit.click
  end

  def and_i_click_add_user
    users_check_page.add_user.click
  end

  def then_i_should_see_the_users_name_listed
    expect(users_check_page).to have_text("Willy Wonka")
  end

  def and_i_should_see_the_users_email_listed
    expect(users_check_page).to have_text("willy.wonka@bat_school.com")
  end

  def and_the_user_should_be_added_to_the_database
    expect(Provider.find_by(provider_name: "Batman's Chocolate School").users.where(email: "willy.wonka@bat_school.com").blank?).to be(false)
  end

  def given_i_visit_the_users_new_page
    users_new_page.load(provider_code: @provider.provider_code)
  end

  def then_it_should_display_the_correct_error_messages
    expect(users_new_page.error_summary).to have_text("Enter a first name")
    expect(users_new_page.error_summary).to have_text("Enter a last name")
    expect(users_new_page.error_summary).to have_text("Enter an email address")
  end
end
