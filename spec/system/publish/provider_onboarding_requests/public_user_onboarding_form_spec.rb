require "rails_helper"

RSpec.describe "Provider facing onboarding form (publish side)", type: :system do
  let!(:onboarding_request) { create(:providers_onboarding_form_request) }
  let(:form_data) { attributes_for(:providers_onboarding_form_request, :with_form_details) }

  scenario "viewing the provider onboarding form as a public user" do
    when_i_visit_the_onboarding_form
    then_i_see_the_onboarding_form_fields
  end

  scenario "successfully submitting the provider onboarding form as a public user" do
    when_i_visit_the_onboarding_form
    and_i_fill_in_valid_onboarding_details
    and_i_submit_the_onboarding_form
    then_i_am_taken_to_the_submitted_page
    and_the_onboarding_request_is_marked_as_submitted
    and_the_details_are_saved_correctly
    and_i_see_the_confirmation_message_content
  end

  scenario "attempting to revisit a submitted onboarding form as a public user" do
    submitted_request = create(:providers_onboarding_form_request, :submitted)
    when_i_visit_the_onboarding_form_that_has_been_submitted(submitted_request)
    then_i_see_the_read_only_form_fields
    and_i_see_already_submitted_message
    and_i_do_not_see_the_submit_button
  end

  # Helper methods

  def when_i_visit_the_onboarding_form
    visit publish_provider_onboarding_path(onboarding_request.uuid)
  end

  def then_i_see_the_onboarding_form_fields
    expect(page).to have_content("Add an organisation to Publish")
    expect(page).to have_css("h2.govuk-heading-m", text: "Organisation details")
    expect(page).to have_css("h2.govuk-heading-m", text: "Contact details")
    expect(page).to have_css("h2.govuk-heading-m", text: "User details")
    expect(page).to have_field("Organisation name")
    expect(page).to have_field("UK provider reference number (UKPRN)")
    expect(page).to have_content("Are you an accredited provider?")
    expect(page).to have_field("Yes", type: "radio")
    expect(page).to have_field("No", type: "radio")
    expect(page).to have_field("Unique reference number (URN)")
    expect(page).to have_field("Contact email address")
    expect(page).to have_field("Phone number")
    expect(page).to have_field("Organisation website")
    expect(page).to have_field("Address line 1")
    expect(page).to have_field("Address line 2")
    expect(page).to have_field("Address line 3")
    expect(page).to have_field("Town or city")
    expect(page).to have_field("County")
    expect(page).to have_field("Postcode")
    expect(page).to have_field("Email address")
    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
  end

  def and_i_fill_in_valid_onboarding_details
    # Organisation details
    fill_in "Organisation name", with: form_data[:provider_name]
    fill_in "UK provider reference number (UKPRN)", with: form_data[:ukprn]

    choose(form_data[:accredited_provider] ? "Yes" : "No")
    fill_in "Unique reference number (URN)", with: form_data[:urn]

    # Contact details
    fill_in "Contact email address", with: form_data[:contact_email_address]
    fill_in "Phone number", with: form_data[:telephone]
    fill_in "Organisation website", with: form_data[:website]
    fill_in "Address line 1", with: form_data[:address_line_1]
    fill_in "Address line 2", with: form_data[:address_line_2]
    fill_in "Address line 3", with: form_data[:address_line_3]
    fill_in "Town or city", with: form_data[:town_or_city]
    fill_in "County", with: form_data[:county]
    fill_in "Postcode", with: form_data[:postcode]

    # User details
    fill_in "Email address", with: form_data[:email_address]
    fill_in "First name", with: form_data[:first_name]
    fill_in "Last name", with: form_data[:last_name]
  end

  def and_i_submit_the_onboarding_form
    click_button "Submit"
  end

  def then_i_am_taken_to_the_submitted_page
    expect(page).to have_current_path(
      submitted_publish_provider_onboarding_path(onboarding_request.uuid),
    )
  end

  def and_the_onboarding_request_is_marked_as_submitted
    onboarding_request.reload
    expect(onboarding_request.status).to eq("submitted")
  end

  def and_the_details_are_saved_correctly
    onboarding_request.reload

    expect(onboarding_request.provider_name).to eq(form_data[:provider_name])
    expect(onboarding_request.ukprn).to eq(form_data[:ukprn])
    expect(onboarding_request.accredited_provider).to eq(form_data[:accredited_provider])
    expect(onboarding_request.urn).to eq(form_data[:urn])

    expect(onboarding_request.contact_email_address).to eq(form_data[:contact_email_address])
    expect(onboarding_request.telephone).to eq(form_data[:telephone])
    expect(onboarding_request.website).to eq(form_data[:website])

    expect(onboarding_request.address_line_1).to eq(form_data[:address_line_1])
    expect(onboarding_request.address_line_2).to eq(form_data[:address_line_2])
    expect(onboarding_request.address_line_3).to eq(form_data[:address_line_3])
    expect(onboarding_request.town_or_city).to eq(form_data[:town_or_city])
    expect(onboarding_request.county).to eq(form_data[:county])
    expect(onboarding_request.postcode).to eq(form_data[:postcode])

    expect(onboarding_request.email_address).to eq(form_data[:email_address])
    expect(onboarding_request.first_name).to eq(form_data[:first_name])
    expect(onboarding_request.last_name).to eq(form_data[:last_name])
  end

  def and_i_see_the_confirmation_message_content
    within(".govuk-panel.govuk-panel--confirmation") do
      expect(page).to have_content(
        "Provider onboarding request submitted for #{onboarding_request.provider_name}",
      )
    end
    # "Form sent" message exists
    expect(page).to have_css("h2.govuk-heading-m", text: "What happens next")
    expect(page).to have_content("We've sent your form to the Publish support team.")
    expect(page).to have_content("They will contact you either to confirm the onboarding process is complete, or to ask for more information.")
    expect(page).to have_content("This form cannot be edited.")
    expect(page).to have_css("h2.govuk-heading-m", text: "Get help with the onboarding process")
    # Check support email is rendered as a mailto link
    support_email = "becomingateacher@digital.education.gov.uk"
    if support_email
      expect(page).to have_link(
        support_email,
        href: "mailto:#{support_email}",
      )
    end
    expect(page).to have_content("You can close this window or tab.")
  end

  def when_i_visit_the_onboarding_form_that_has_been_submitted(submitted_request)
    visit publish_provider_onboarding_path(submitted_request.uuid)
  end

  def and_i_see_already_submitted_message
    expect(page).to have_content("This form has already been submitted and can no longer be edited. Please contact the Publish support team if you need assistance.")
    expect(page).to have_css(".govuk-inset-text.govuk-inset-text--warning")
  end

  def then_i_see_the_read_only_form_fields
    expect(page).to have_field("Organisation name", disabled: true)
    expect(page).to have_field("UK provider reference number (UKPRN)", disabled: true)
    expect(page).to have_field("Unique reference number (URN)", disabled: true)
    expect(page).to have_field("Contact email address", disabled: true)
    expect(page).to have_field("Phone number", disabled: true)
    expect(page).to have_field("Organisation website", disabled: true)
    expect(page).to have_field("Address line 1", disabled: true)
    expect(page).to have_field("Address line 2", disabled: true)
    expect(page).to have_field("Address line 3", disabled: true)
    expect(page).to have_field("Town or city", disabled: true)
    expect(page).to have_field("County", disabled: true)
    expect(page).to have_field("Postcode", disabled: true)
    expect(page).to have_field("Email address", disabled: true)
    expect(page).to have_field("First name", disabled: true)
    expect(page).to have_field("Last name", disabled: true)
  end

  def and_i_do_not_see_the_submit_button
    expect(page).not_to have_button("Submit")
  end
end
