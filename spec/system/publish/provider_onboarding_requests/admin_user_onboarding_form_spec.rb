require "rails_helper"

RSpec.describe "Provider facing onboarding form (publish side) - admin", type: :system do
  let(:admin_user) { create(:user, :admin) }
  let!(:onboarding_request) { create(:providers_onboarding_form_request, :submitted) }

  scenario "revisiting a submitted onboarding form as an admin user" do
    given_i_am_an_admin_user
    when_i_visit_the_onboarding_form
    then_i_see_a_back_link_to_show_page
    then_i_do_not_see_already_submitted_message
    then_i_see_the_completed_form_fields
    and_i_see_the_submit_button
    and_i_can_edit_the_form_if_needed
    then_i_see_a_back_link_to_show_page
  end

  # Helper methods

  def given_i_am_an_admin_user
    sign_in_system_test(user: admin_user)
  end

  def when_i_visit_the_onboarding_form
    visit publish_provider_onboarding_path(onboarding_request.uuid)
  end

  def then_i_see_a_back_link_to_show_page
    expect(page).to have_link(
      "Back",
      href: support_providers_onboarding_form_request_path(onboarding_request),
    )
  end

  def then_i_do_not_see_already_submitted_message
    expect(page).not_to have_content(
      "This form has already been submitted and can no longer be edited. Please contact the Publish support team if you need assistance.",
    )
    expect(page).not_to have_css(".govuk-inset-text.govuk-inset-text--warning")
  end

  def then_i_see_the_completed_form_fields
    expect(page).to have_field("Organisation name", with: onboarding_request.provider_name)
    expect(page).to have_field("UK provider reference number (UKPRN)", with: onboarding_request.ukprn)
    expect(page).to have_field("Unique reference number (URN)", with: onboarding_request.urn)
    expect(page).to have_field("Contact email address", with: onboarding_request.contact_email_address)
    expect(page).to have_field("Phone number", with: onboarding_request.telephone)
    expect(page).to have_field("Organisation website", with: onboarding_request.website)
    expect(page).to have_field("Address line 1", with: onboarding_request.address_line_1)
    expect(page).to have_field("Address line 2") # optional, often blank
    expect(page).to have_field("Address line 3") # optional, often blank
    expect(page).to have_field("Town or city", with: onboarding_request.town_or_city)
    expect(page).to have_field("County", with: onboarding_request.county)
    expect(page).to have_field("Postcode", with: onboarding_request.postcode)
    expect(page).to have_field("Email address", with: onboarding_request.email_address)
    expect(page).to have_field("First name", with: onboarding_request.first_name)
    expect(page).to have_field("Last name", with: onboarding_request.last_name)
  end

  def and_i_see_the_submit_button
    expect(page).to have_button("Submit")
  end

  def and_i_can_edit_the_form_if_needed
    new_name = "Updated #{onboarding_request.provider_name}"

    fill_in "Organisation name", with: new_name
    click_button "Submit"

    expect(page).to have_current_path(
      publish_provider_onboarding_submitted_path(onboarding_request.uuid),
    )

    onboarding_request.reload
    expect(onboarding_request.provider_name).to eq(new_name)

    within(".govuk-panel.govuk-panel--confirmation") do
      expect(page).to have_content(
        "Provider onboarding request submitted for #{new_name}",
      )
    end
  end
end
