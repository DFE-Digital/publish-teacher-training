# frozen_string_literal: true

require "rails_helper"

feature "Editing contact details", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_contact_details_page
  end

  scenario "i can update my visa sponsorships" do
    and_i_set_my_contact_details
    and_i_submit
    then_i_should_see_a_success_message
    and_the_contact_details_are_updated
  end

  scenario "updating with invalid data" do
    and_i_submit_with_invalid_data
    then_i_should_see_a_an_error_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def when_i_visit_the_contact_details_page
    publish_provider_contact_details_edit_page.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year)
  end

  def and_i_set_my_contact_details
    publish_provider_contact_details_edit_page.email.set "updated@email.com"
    publish_provider_contact_details_edit_page.telephone.set "11111 111111"
    publish_provider_contact_details_edit_page.address1.set "123 Updated Street"
  end

  def and_i_submit
    publish_provider_contact_details_edit_page.save_and_publish.click
  end

  def and_i_submit_with_invalid_data
    publish_provider_contact_details_edit_page.email.set(nil)
    publish_provider_contact_details_edit_page.save_and_publish.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.published"))
  end

  def and_the_contact_details_are_updated
    within_summary_row "Email address" do
      expect(page).to have_content "updated@email.com"
    end

    within_summary_row "Telephone number" do
      expect(page).to have_content "11111 111111"
    end

    within_summary_row "Contact address" do
      expect(page).to have_content "123 Updated Street"
    end
  end

  def then_i_should_see_a_an_error_message
    expected_error_message = "Enter an email address in the correct format, like name@example.com"

    expect(publish_provider_contact_details_edit_page.errors).to include(expected_error_message)
  end

  def provider
    @current_user.providers.first
  end
end
