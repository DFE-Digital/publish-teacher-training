# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support - View Provider Details", service: :support, type: :system do
  include ActionView::Helpers::TextHelper
  include ProvidersOnboardingFormRequestsHelper

  let(:user) { create(:user, :admin) }
  let!(:onboarding_request) { create(:providers_onboarding_form_request, :submitted) }

  before do
    given_i_am_authenticated
  end

  context "when viewing the details submitted for an existing onboarding request" do
    before do
      when_i_visit_the_show_page_for(onboarding_request)
    end

    scenario "I can view all details submitted in the onboarding request" do
      then_i_am_on_the_show_page_for(onboarding_request)
      then_i_see_form_name_and_link(onboarding_request)
      then_i_see_all_provider_details_for(onboarding_request)
      then_i_see_action_buttons_and_cancel_link
    end

    scenario "I can accept an onboarding request" do
      when_i_click_accept

      then_i_am_on_the_providers_onboarding_form_requests_page
      then_status_should_be("Closed", onboarding_request)
    end

    scenario "I can reject an onboarding request" do
      when_i_click_reject

      then_i_am_on_the_providers_onboarding_form_requests_page
      then_status_should_be("Rejected", onboarding_request)
    end

    scenario "I can navigate back to the onboarding requests list via Cancel" do
      then_i_click_cancel

      then_i_am_on_the_providers_onboarding_form_requests_page
      then_i_see_providers_onboarding_form_requests_table
    end
  end
end
