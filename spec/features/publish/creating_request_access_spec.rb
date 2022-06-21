# frozen_string_literal: true

require "rails_helper"

feature "Creating request access" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_i_visit_the_request_access_new_page
  end

  scenario "creating request access with invalid data" do
    and_i_submit_with_invalid_data
    then_i_should_see_an_error_message
  end

  scenario "creating request access with valid data" do
    and_i_submit_with_valid_data
    then_i_should_see_a_success_message
  end

private

  def then_i_should_see_a_success_message
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/users")
    expect(page).to have_content("Your request for access has been submitted")
  end

  def given_i_am_authenticated_as_a_provider_user
    user = create(:user, :with_provider)
    given_i_am_authenticated(user:)
  end

  def and_i_visit_the_request_access_new_page
    request_access_new_page.load(provider_code: provider.provider_code)
  end

  def and_i_click_on_request_access
    request_access_new_page.request_access.click
  end

  def and_i_submit_with_valid_data
    request_access_new_page.first_name.set("first_name")
    request_access_new_page.last_name.set("last_name")
    request_access_new_page.email_address.set("email@address")
    request_access_new_page.organisation.set("organisation")
    request_access_new_page.reason.set("reason")
    and_i_click_on_request_access
  end

  def and_i_submit_with_invalid_data
    request_access_new_page.first_name.set("")
    request_access_new_page.last_name.set("")
    request_access_new_page.email_address.set("")
    request_access_new_page.organisation.set("")
    request_access_new_page.reason.set("")
    and_i_click_on_request_access
  end

  def then_i_should_see_an_error_message
    expected_error_messages = ["Enter a first name", "Enter a last name", "Enter an email address", "Enter their organisation", "Enter why they need access"]
    expect(request_access_new_page.error_messages).to eq(expected_error_messages)
  end

  def provider
    @current_user.providers.first
  end
end
