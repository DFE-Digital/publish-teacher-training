require "rails_helper"

RSpec.describe "Support console providers onboarding form requests", service: :support do
  include ActionView::Helpers::TextHelper
  include ProvidersOnboardingFormRequestsHelper
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  context "when navigating to the providers onboarding form requests page via the support console" do
    before do
      create_list(:providers_onboarding_form_request, 3)
      when_i_navigate_to_the_providers_onboarding_form_requests_page
    end

    scenario "user sees providers onboarding form requests table" do
      then_i_see_providers_onboarding_form_requests_table
      then_i_see_recent_providers_onboarding_form_requests_entries
    end

    scenario "check for backlink presence and navigation on the onboarding page", travel: mid_cycle do
      then_i_see_backlink_to_support_homepage
      then_i_click_back_button
      then_i_am_on_the_support_homepage
    end

    context "with more than one page of requests" do
      before do
        create_list(:providers_onboarding_form_request, 15)
        when_i_visit_the_providers_onboarding_form_requests_page
      end

      scenario "user sees pagination controls and can navigate to next page" do
        then_i_see_first_page_of_requests_with_pagination

        click_link "Next"

        then_i_see_second_page_of_requests_with_pagination
      end

      # Can be removed when all tickets related to providers onboarding are done / merged
      context "when in development environment" do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
          visit support_root_path
        end

        scenario "Onboarding tab is visible" do
          expect(page).to have_link("Onboarding")
        end
      end

      # Can be removed when all tickets related to providers onboarding are done / merged
      context "when in production environment" do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
          visit support_root_path
        end

        scenario "Onboarding tab is not visible" do
          expect(page).not_to have_link("Onboarding")
        end
      end
    end
  end
end
