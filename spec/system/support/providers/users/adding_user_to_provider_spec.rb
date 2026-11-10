# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding user to provider as an admin", :publish_features, travel: mid_cycle do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider
  end

  describe "Adding user to organisation" do
    scenario "With valid details" do
      given_i_visit_the_support_provider_users_index_page
      and_the_user_i_want_to_add_has_not_already_been_added
      and_i_click_add_user_in_publish
      then_i_am_on_the_publish_personal_details_page

      and_i_fill_in_first_name
      and_i_fill_in_last_name
      and_i_fill_in_email
      and_i_continue
      then_i_should_be_on_the_publish_check_page
      and_the_user_should_not_be_added_to_the_database

      when_i_click_change_first_name
      and_i_enter_a_new_first_name
      and_i_continue
      and_i_click_add_user

      then_i_am_back_on_the_support_provider_users_index_page
      and_i_should_see_the_success_message
      then_i_should_see_the_users_name_listed
      and_i_should_see_the_users_email_listed
      and_the_user_should_be_added_to_the_database
    end

    scenario "With invalid details" do
      given_i_visit_the_publish_add_user_page_from_support
      and_i_continue

      then_it_should_display_the_correct_error_messages
    end

    scenario "With an email that already exists" do
      given_i_visit_the_publish_add_user_page_from_support
      and_i_fill_in_first_name
      and_i_fill_in_last_name
      and_i_fill_in_email_with_one_that_is_already_associated_with_the_provider
      when_i_continue
      then_i_see_the_validation_error_message
      and_i_am_still_on_the_publish_personal_details_page
    end
  end

  def and_there_is_a_provider
    @provider = create(:provider, :with_users, provider_name: "School of bats")
  end

  def given_i_visit_the_support_provider_users_index_page
    support_provider_users_index_page.load(recruitment_cycle_year: Find::CycleTimetable.current_year, provider_id: @provider.id)
  end

  def given_i_visit_the_publish_add_user_page_from_support
    visit new_publish_provider_user_path(
      provider_code: @provider.provider_code,
      return_to: "support",
      recruitment_cycle_year: @provider.recruitment_cycle_year,
    )
  end

  def and_i_click_add_user_in_publish
    support_provider_users_index_page.add_user_in_publish.click
  end

  def then_i_am_on_the_publish_personal_details_page
    expect(publish_users_new_page).to be_displayed(provider_code: @provider.provider_code)
  end

  def and_i_am_still_on_the_publish_personal_details_page
    expect(page).to have_current_path(
      publish_provider_users_path(
        @provider.provider_code,
        return_to: "support",
        recruitment_cycle_year: @provider.recruitment_cycle_year,
      ),
    )
    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_link(
      "Cancel",
      href: support_recruitment_cycle_provider_users_path(@provider.recruitment_cycle_year, @provider),
    )
  end

  def and_i_continue
    click_link_or_button "Continue"
  end

  alias_method :when_i_continue, :and_i_continue

  def and_i_fill_in_first_name
    publish_users_new_page.first_name.set("Asa")
  end

  def and_i_fill_in_last_name
    publish_users_new_page.last_name.set("Bernhard")
  end

  def and_i_fill_in_email
    publish_users_new_page.email.set("viola_fisher@boyle.io")
  end

  def and_i_fill_in_email_with_one_that_is_already_associated_with_the_provider
    publish_users_new_page.email.set(@provider.users.first.email)
  end

  def and_i_click_add_user
    publish_users_check_page.add_user.click
  end

  def then_i_should_be_on_the_publish_check_page
    expect(publish_users_check_page).to be_displayed(provider_code: @provider.provider_code)
  end

  def then_i_am_back_on_the_support_provider_users_index_page
    expect(support_provider_users_index_page).to be_displayed(
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      provider_id: @provider.id,
    )
  end

  def and_i_should_see_the_success_message
    expect(support_provider_users_index_page).to have_success_notification
    expect(page).to have_text("User added")
  end

  def then_i_should_see_the_users_name_listed
    expect(page).to have_text("Aba Bernhard")
  end

  def and_i_should_see_the_users_email_listed
    expect(page).to have_text("viola_fisher@boyle.io")
  end

  def and_the_user_i_want_to_add_has_not_already_been_added
    expect(page).to have_no_text("viola_fisher@boyle.io")
  end

  def then_it_should_display_the_correct_error_messages
    expect(publish_users_new_page.error_summary).to have_text("Enter a first name")
    expect(publish_users_new_page.error_summary).to have_text("Enter a last name")
    expect(publish_users_new_page.error_summary).to have_text("Enter an email address")
  end

  def and_the_user_should_be_added_to_the_database
    expect(Provider.find_by(provider_name: "School of bats").users.where(email: "viola_fisher@boyle.io").blank?).to be(false)
  end

  def and_the_user_should_not_be_added_to_the_database
    expect(Provider.find_by(provider_name: "School of bats").users.where(email: "viola_fisher@boyle.io").blank?).to be(true)
  end

  def when_i_click_change_first_name
    publish_users_check_page.change_first_name.click
  end

  def and_i_enter_a_new_first_name
    publish_users_new_page.first_name.set("Aba")
  end

  def then_i_see_the_validation_error_message
    expect(page).to have_css(".govuk-error-summary__body", text: "Email address already in use")
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end
end
