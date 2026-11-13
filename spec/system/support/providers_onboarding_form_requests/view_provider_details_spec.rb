# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support - View Provider Details", service: :support, type: :system do
  include ActionView::Helpers::TextHelper
  include ProvidersOnboardingFormRequestsHelper

  let(:user) { create(:user, :admin) }
  let!(:onboarding_request) { create(:providers_onboarding_form_request, :ready_to_onboard) }

  before do
    find_or_create(:recruitment_cycle)
    given_i_am_authenticated
  end

  context "when viewing the details submitted for an existing onboarding request" do
    before do
      when_i_visit_the_show_page_for(onboarding_request)
    end

    scenario "I can change the provider type from the details page" do
      click_link "Change", href: support_return_path(anchor: "providers-onboarding-form-request-provider-type-field")

      expect(page).to have_current_path(publish_provider_onboarding_path(onboarding_request.uuid), ignore_query: true)
      expect(page).to have_checked_field("School")

      choose "Higher education institution (HEI)"
      click_button "Continue"

      expect(page).to have_current_path(support_providers_onboarding_form_request_path(onboarding_request))
      expect(page).to have_css(".govuk-notification-banner__heading", exact_text: "Provider type updated")
      expect(page).to have_content("Higher education institution (HEI)")
      expect(onboarding_request.reload.provider_type).to eq("university")
    end

    scenario "I can change the provider name from the details page" do
      click_link "Change", href: support_return_path(anchor: "providers-onboarding-form-request-provider-name-field")

      expect(page).to have_field("Organisation name", with: "Northshore Training")

      fill_in "Organisation name", with: "Updated Northshore"
      click_button "Continue"

      expect(page).to have_current_path(support_providers_onboarding_form_request_path(onboarding_request))
      expect(page).to have_css(".govuk-notification-banner__heading", exact_text: "Provider name updated")
      expect(page).to have_content("Updated Northshore")
      expect(onboarding_request.reload.provider_name).to eq("Updated Northshore")
    end

    scenario "I can change the UKPRN from the details page" do
      click_link "Change", href: support_return_path(anchor: "providers-onboarding-form-request-ukprn-field")

      expect(page).to have_field("UK provider reference number (UKPRN)", with: "12345678")

      fill_in "UK provider reference number (UKPRN)", with: "12345679"
      click_button "Continue"

      expect(page).to have_current_path(support_providers_onboarding_form_request_path(onboarding_request))
      expect(page).to have_css(".govuk-notification-banner__heading", exact_text: "UK provider reference number (UKPRN) updated")
      expect(page).to have_content("12345679")
      expect(onboarding_request.reload.ukprn).to eq("12345679")
    end

    scenario "I can change whether the organisation is an accredited provider" do
      onboarding_request.update!(
        accredited_provider: true,
        provider_type: "university",
        accredited_provider_number: "1234",
        urn: nil,
      )
      when_i_visit_the_show_page_for(onboarding_request)

      click_link "Change", href: support_return_path(anchor: "providers-onboarding-form-request-accredited-provider-field-error")

      expect(page).to have_checked_field("Yes")

      choose "No"
      click_button "Continue"

      expect(page).to have_current_path(support_providers_onboarding_form_request_path(onboarding_request))
      expect(page).to have_css(".govuk-notification-banner__heading", exact_text: "Is the organisation an accredited provider? updated")
      expect(page).to have_content("No")
      expect(onboarding_request.reload.accredited_provider).to be(false)
    end

    scenario "I can change the URN from the details page" do
      click_link "Change", href: support_return_path(anchor: "providers-onboarding-form-request-urn-field")

      expect(page).to have_field("Unique reference number (URN)", with: "123456")

      fill_in "Unique reference number (URN)", with: "654321"
      click_button "Continue"

      expect(page).to have_current_path(support_providers_onboarding_form_request_path(onboarding_request))
      expect(page).to have_css(".govuk-notification-banner__heading", exact_text: "Unique reference number (URN) updated")
      expect(page).to have_content("654321")
      expect(onboarding_request.reload.urn).to eq("654321")
    end

    scenario "I can change an accredited provider number from the details page" do
      onboarding_request.update!(
        accredited_provider: true,
        provider_type: "university",
        accredited_provider_number: "1234",
        urn: nil,
      )
      when_i_visit_the_show_page_for(onboarding_request)

      click_link "Change", href: support_return_path(anchor: "providers-onboarding-form-request-accredited-provider-number-field")

      fill_in "Accredited provider number", with: "1567"
      click_button "Continue"

      expect(page).to have_current_path(support_providers_onboarding_form_request_path(onboarding_request))
      expect(page).to have_css(".govuk-notification-banner__heading", exact_text: "Accredited provider number updated")
      expect(page).to have_content("1567")
      expect(onboarding_request.reload.accredited_provider_number).to eq("1567")
    end

    scenario "I can add a missing accredited provider number from the details page" do
      onboarding_request.update!(
        accredited_provider: true,
        provider_type: "university",
        accredited_provider_number: nil,
        urn: nil,
      )
      when_i_visit_the_show_page_for(onboarding_request)

      click_link "Enter accredited provider number"

      fill_in "Accredited provider number", with: "1234"
      click_button "Continue"

      expect(page).to have_current_path(support_providers_onboarding_form_request_path(onboarding_request))
      expect(page).to have_css(".govuk-notification-banner__heading", exact_text: "Accredited provider number updated")
      expect(page).to have_content("1234")
      expect(onboarding_request.reload.accredited_provider_number).to eq("1234")
    end

    scenario "I can view all details submitted in the onboarding request" do
      then_i_am_on_the_show_page_for(onboarding_request)
      then_i_see_form_name_and_link(onboarding_request)
      then_i_see_all_provider_details_for(onboarding_request)
      then_i_see_action_buttons_and_cancel_link
    end

    scenario "I can onboard a provider" do
      when_i_click_onboard_provider

      then_i_am_on_the_new_provider_organisation_page(onboarding_request)
      then_i_see_the_onboarded_success_banner(onboarding_request)
      then_the_provider_and_first_user_are_created(onboarding_request)
    end

    scenario "I do not see onboard or reject actions once a provider has been onboarded" do
      when_i_click_onboard_provider
      when_i_visit_the_show_page_for(onboarding_request)

      then_i_do_not_see_onboard_or_reject_actions
      then_only_one_provider_exists_for(onboarding_request)
    end

    scenario "I can onboard an accredited provider" do
      onboarding_request.update!(
        accredited_provider: true,
        provider_type: "university",
        accredited_provider_number: "1234",
        urn: nil,
      )

      when_i_click_onboard_provider

      then_i_am_on_the_new_provider_organisation_page(onboarding_request)
      then_i_see_the_onboarded_success_banner(onboarding_request)
      then_the_accredited_provider_is_created(onboarding_request)
    end

    scenario "I can reject an onboarding request" do
      when_i_click_reject

      then_i_am_on_the_providers_onboarding_form_requests_page
      then_status_should_be("Rejected", onboarding_request)

      when_i_visit_the_show_page_for(onboarding_request)
      then_i_do_not_see_onboard_or_reject_actions
    end

    scenario "I can navigate back to the onboarding requests list via Cancel" do
      then_i_click_cancel

      then_i_am_on_the_providers_onboarding_form_requests_page
      then_i_see_providers_onboarding_form_requests_table
    end

    def support_return_path(anchor:)
      publish_provider_onboarding_path(onboarding_request.uuid, return_to: "support", anchor:)
    end
  end
end
