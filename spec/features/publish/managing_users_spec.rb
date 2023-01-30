# frozen_string_literal: true

require 'rails_helper'

feature 'Adding user to organisation as a provider user', { can_edit_current_and_next_cycles: false } do
  before do
    allow(Settings.features).to receive(:user_management).and_return(true)
    given_i_am_authenticated_as_a_provider_user
  end

  describe 'Adding user to organisation' do
    scenario 'With valid details' do
      given_i_visit_the_publish_users_index_page
      when_the_user_i_want_to_add_has_not_already_been_added
      and_i_click_add_user
      and_i_fill_in_first_name
      and_i_fill_in_last_name
      and_i_fill_in_email
      and_i_continue
      and_i_am_on_the_check_page
      then_the_user_should_not_be_in_the_database

      given_i_click_change_first_name
      when_i_enter_a_new_first_name
      and_i_continue
      and_i_click_add_user
      then_i_should_see_the_users_name_and_email_listed
      and_the_user_should_be_added_to_the_database
    end

    scenario 'With invalid details' do
      given_i_visit_the_publish_users_new_page
      and_i_continue

      then_it_should_display_the_correct_error_messages
    end
  end

  describe 'Viewing a user in an organisation' do
    scenario 'With an existing user' do
      given_i_visit_the_publish_users_index_page
      when_i_click_on_the_user
      i_should_be_on_the_publish_users_show_page
      then_the_users_name_should_be_displayed
    end
  end

  describe 'Editing a user in an organisation' do
    context 'User does not have a dfe sign in account' do
      before do
        given_that_the_user_does_not_have_a_dfe_signin_account
        when_i_visit_the_publish_users_index_page
        and_i_click_on_the_user
      end

      context 'Changing an email address' do
        scenario 'with valid details' do
          given_i_click_change_email_address
          when_i_enter_a_new_valid_email
          and_i_continue
          and_the_new_email_is_displayed
          and_the_warning_email_text_should_be_displayed
          and_the_user_should_not_have_changed_in_the_database
          and_i_click_update_user
          then_the_user_should_have_changed_in_the_database
        end

        scenario 'with invalid details' do
          given_i_click_change_email_address
          when_i_enter_a_new_invalid_email
          and_i_continue
          then_i_should_see_a_validation_error_message
        end
      end

      scenario 'Changing a first name' do
        given_i_click_change_first_name
        when_i_edit_and_enter_a_new_first_name
        and_i_continue
        and_i_see_the_new_first_name_is_displayed
        and_the_warning_email_text_should_not_be_displayed
        and_the_first_name_should_not_have_updated_in_the_database
        and_i_click_update_user
        then_the_first_name_should_have_updated_in_the_database
      end

      scenario 'Changing a last name' do
        given_i_click_change_last_name
        when_i_edit_and_enter_a_new_last_name
        and_i_continue
        and_i_see_the_new_last_name_is_displayed
        and_the_warning_email_text_should_not_be_displayed
        and_the_last_name_should_not_have_updated_in_the_database
        and_i_click_update_user
        then_the_last_name_should_have_updated_in_the_database
      end
    end

    context 'User has a dfe signin account' do
      scenario 'Changing any details' do
        given_the_user_has_an_associated_dfe_signin_account
        when_i_visit_the_publish_users_index_page
        and_i_click_on_the_user
        then_i_should_not_see_any_change_links
      end
    end
  end

  describe 'Removing a user in an organisation' do
    scenario 'With an existing user' do
      given_i_visit_the_publish_users_index_page
      when_i_click_on_user_two
      and_i_click_remove_user
      and_i_confirm
      then_the_user_should_be_deleted
    end
  end

  def given_that_the_user_does_not_have_a_dfe_signin_account
    @user.update(sign_in_user_id: nil)
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider, provider_name: "Batman's Chocolate School")
    @user = create(:user, first_name: 'Mr', last_name: 'User', providers: [@provider])
    @user2 = create(:user, first_name: 'Mr', last_name: 'Cool', providers: [@provider])
    given_i_am_authenticated(user: @user)
  end

  def given_i_visit_the_publish_users_index_page
    publish_users_index_page.load(provider_code: @provider.provider_code)
  end

  alias_method :when_i_visit_the_publish_users_index_page, :given_i_visit_the_publish_users_index_page

  def when_the_user_i_want_to_add_has_not_already_been_added
    expect(publish_users_index_page).not_to have_text('willy.wonka@bat-school.com')
  end

  def and_i_click_add_user
    publish_users_index_page.add_user.click
  end

  def and_i_fill_in_first_name
    publish_users_new_page.first_name.set('Silly')
  end

  def and_i_fill_in_last_name
    publish_users_new_page.last_name.set('Wonka')
  end

  def and_i_fill_in_email
    publish_users_new_page.email.set('willy.wonka@bat-school.com')
  end

  def and_i_continue
    click_button 'Continue'
  end

  def and_i_am_on_the_check_page
    expect(publish_users_check_page).to be_displayed(provider_code: @provider.provider_code)
  end

  def then_the_user_should_not_be_in_the_database
    expect(Provider.find_by(provider_name: "Batman's Chocolate School").users.exists?(email: 'willy.wonka@bat-school.com')).to be(false)
  end

  def and_the_user_should_not_have_changed_in_the_database
    expect(Provider.find_by(provider_name: "Batman's Chocolate School").users.exists?(email: 'a-changed-email@address.com')).to be(false)
  end

  def then_the_user_should_have_changed_in_the_database
    expect(Provider.find_by(provider_name: "Batman's Chocolate School").users.exists?(email: 'a-changed-email@address.com')).to be(true)
  end

  def given_i_click_change_first_name
    publish_users_check_page.change_first_name.click
  end

  def when_i_enter_a_new_first_name
    publish_users_new_page.first_name.set('Willy')
  end

  def when_i_enter_a_new_valid_email
    publish_users_edit_page.email.set('a-changed-email@address.com')
  end

  def when_i_edit_and_enter_a_new_first_name
    publish_users_edit_page.first_name.set('New first name')
  end

  def when_i_edit_and_enter_a_new_last_name
    publish_users_edit_page.first_name.set('New last name')
  end

  def and_the_warning_email_text_should_be_displayed
    expect(page).to have_text('Warning The user will be sent an email to tell them you’ve changed their email address')
  end

  def when_i_enter_a_new_invalid_email
    fill_in 'Email address', with: 'invalid_email@'
  end

  def and_i_see_the_new_first_name_is_displayed
    expect(page).to have_text('New first name')
  end

  def and_the_warning_email_text_should_not_be_displayed
    expect(page).not_to have_text('Warning The user will be sent an email to tell them you’ve changed their email address')
  end

  def and_i_see_the_new_last_name_is_displayed
    expect(page).to have_text('New last name')
  end

  def given_the_user_has_an_associated_dfe_signin_account
    @user.update(sign_in_user_id: 'SOME-SORT-OF-IDENTIFICATION-CODE')
  end

  def then_i_should_not_see_any_change_links
    expect(page).not_to have_link 'Change'
  end

  def and_i_click_add_user
    publish_users_check_page.add_user.click
  end

  def then_i_should_see_the_users_name_and_email_listed
    expect(publish_users_check_page).to have_text('Willy Wonka')
    expect(publish_users_check_page).to have_text('willy.wonka@bat-school.com')
  end

  def and_the_user_should_be_added_to_the_database
    expect(Provider.find_by(provider_name: "Batman's Chocolate School").users.where(email: 'willy.wonka@bat-school.com').blank?).to be(false)
  end

  def given_i_visit_the_publish_users_new_page
    publish_users_new_page.load(provider_code: @provider.provider_code)
  end

  def then_it_should_display_the_correct_error_messages
    expect(publish_users_new_page.error_summary).to have_text('Enter a first name')
    expect(publish_users_new_page.error_summary).to have_text('Enter a last name')
    expect(publish_users_new_page.error_summary).to have_text('Enter an email address')
  end

  def and_i_click_on_the_user
    click_link 'Mr User'
  end

  alias_method :when_i_click_on_the_user, :and_i_click_on_the_user

  def when_i_click_on_user_two
    click_link 'Mr Cool'
  end

  def i_should_be_on_the_publish_users_show_page
    expect(publish_users_show_page).to be_displayed
  end

  def then_the_users_name_should_be_displayed
    expect(publish_users_show_page).to have_text('Mr User')
  end

  def and_i_click_remove_user
    publish_users_show_page.remove_user_link.click
  end

  def given_i_click_change_email_address
    publish_users_show_page.change_email_address.click
  end

  def given_i_click_change_first_name
    publish_users_show_page.change_first_name.click
  end

  def given_i_click_change_last_name
    publish_users_show_page.change_last_name.click
  end

  def and_i_confirm
    publish_users_delete_page.remove_user_button.click
  end

  def then_the_user_should_be_deleted
    expect(publish_provider_users_page).not_to have_text 'Mr Cool'
  end

  def and_the_new_email_is_displayed
    expect(page).to have_text('a-changed-email@address.com')
  end

  def and_i_click_update_user
    click_button 'Update user'
  end

  def then_i_should_see_a_validation_error_message
    expect(page).to have_text('Enter an email address in the correct format, like name@example.com')
  end

  def then_the_first_name_should_have_updated_in_the_database
    expect(user_in_db_with_name('New first name')).to be(true)
  end

  def and_the_first_name_should_not_have_updated_in_the_database
    expect(user_in_db_with_name('New first name')).to be(false)
  end

  def then_the_last_name_should_have_updated_in_the_database
    expect(user_in_db_with_name('New last name')).to be(true)
  end

  def and_the_last_name_should_not_have_updated_in_the_database
    expect(user_in_db_with_name('New last name')).to be(false)
  end

  def user_in_db_with_name(first_name)
    Provider.find_by(provider_name: "Batman's Chocolate School").users.exists?(first_name:)
  end
end
