require "rails_helper"

RSpec.describe "Support console providers onboarding form requests - generating the form", service: :support do
  include ActionView::Helpers::TextHelper
  include ProvidersOnboardingFormRequestsHelper
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  context "when navigating to the providers onboarding form requests page via the support console" do
    before do
      when_i_navigate_to_the_providers_onboarding_form_requests_page
    end

    scenario "user sees 'Generate onboarding form button'" do
      then_i_see_the_generate_onboarding_form_button
    end

    scenario "user clicks 'Generate onboarding form' button and is taken to the new onboarding form request page" do
      when_i_click_to_generate_a_new_onboarding_form

      then_i_am_on_new_onboarding_form_request_page
      then_i_see_fields_on_new_onboarding_form_request_page
    end

    scenario "when onboarding request is submitted successfully, support user is redirected to onboarding requests listing page with success message" do
      when_i_click_to_generate_a_new_onboarding_form

      fill_in "Form name", with: "Test Onboarding Form"
      select user.email, from: "Support agent (optional)"

      then_i_click_submit_button

      then_i_am_on_providers_onboarding_form_requests_listing_page
      then_i_see_success_message_with_form_link
      then_i_see_form_name_and_link_in_table_listing(form_name: "Test Onboarding Form")
      then_last_request_has_valid_uuid
    end

    scenario "when onboarding request is submitted without a form name, user sees validation error message" do
      when_i_click_to_generate_a_new_onboarding_form

      fill_in "Form name", with: ""

      then_i_click_submit_button

      then_i_see_validation_error_message_for_missing_form_name
    end

    scenario "when onboarding request is submitted without a support agent (optional) and zendesk link (optional), it is created successfully" do
      when_i_click_to_generate_a_new_onboarding_form

      fill_in "Form name", with: "Onboarding Form Without Agent and Zendesk"

      then_i_click_submit_button

      then_i_am_on_providers_onboarding_form_requests_listing_page
      then_i_see_success_message_with_form_link
      then_i_see_form_name_and_link_in_table_listing(form_name: "Onboarding Form Without Agent and Zendesk")
      then_i_expect_support_agent_and_zendesk_link_to_be_blank
      then_last_request_has_valid_uuid
    end
  end
end
