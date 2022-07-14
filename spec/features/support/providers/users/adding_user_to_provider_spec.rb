# frozen_string_literal: true

require "rails_helper"

feature "Adding user to provider as an admin" do
  let(:user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user:)
    and_there_is_a_provider
  end

  describe "Adding user to organisation" do
    scenario "With valid details" do
      given_i_visit_the_support_provider_users_index_page
      and_the_user_i_want_to_add_has_not_already_been_added

      when_i_click_add_user
      and_i_fill_in_first_name
      and_i_fill_in_last_name
      and_i_fill_in_email
      and_i_continue
      then_i_should_be_on_the_check_page
      and_the_user_should_not_be_added_to_the_database

      when_i_click_add_user
      then_i_should_see_the_users_name_listed
      and_i_should_see_the_users_email_listed
      and_the_user_should_be_added_to_the_database
    end

    scenario "With invalid details" do
      given_i_visit_the_support_provider_users_new_page
      and_i_continue

      then_i_should_see_the_error_summary
    end
  end

  def and_there_is_a_provider
    @provider = create(:provider, :with_users, provider_name: "School of bats")
  end

  def given_i_visit_the_support_provider_users_index_page
    visit support_provider_users_path(provider_id: @provider.id)
  end

  def and_i_continue
    support_users_new_page.submit.click
  end

  def given_i_visit_the_support_provider_users_new_page
    support_users_new_page.load(provider_id: @provider.id)
  end

  def and_i_fill_in_first_name
    support_users_new_page.first_name.set("Asa")

  end

  def and_i_fill_in_last_name
    support_users_new_page.last_name.set("Bernhard")
  end

  def and_i_fill_in_email
    support_users_new_page.email.set("viola_fisher@boyle.io")
  end

  def when_i_click_add_user
    support_users_check_page.add_user.click
  end

  def then_i_should_be_on_the_check_page
    expect(page).to have_current_path("/support/providers/#{@provider.id}/users/check")
  end

  def then_i_should_see_the_users_name_listed
    expect(page).to have_text("Asa Bernhard")
  end

  def and_i_should_see_the_users_email_listed
    expect(page).to have_text("viola_fisher@boyle.io")
  end

  def and_the_user_i_want_to_add_has_not_already_been_added
    expect(page).not_to have_text("viola_fisher@boyle.io")
  end

  def then_i_should_see_the_error_summary
    expect(support_user_new_page.error_summary).to be_visible
  end

  def and_it_should_display_the_correct_error_messages
    expect(support_user_new_page.error_summary).to have_text("Enter a first name")
    expect(support_user_new_page.error_summary).to have_text("Enter a last name")
    expect(support_user_new_page.error_summary).to have_text("Enter an email address")
  end

  def and_the_user_should_be_added_to_the_database
    expect(Provider.find_by(provider_name: "School of bats").users.where(email: "viola_fisher@boyle.io").blank?).to be(false)
  end

  def and_the_user_should_not_be_added_to_the_database
    expect(Provider.find_by(provider_name: "School of bats").users.where(email: "viola_fisher@boyle.io").blank?).to be(true)
  end
end
