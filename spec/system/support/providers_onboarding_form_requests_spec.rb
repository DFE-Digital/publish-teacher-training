require "rails_helper"

RSpec.describe "Support console providers onboarding form requests", service: :support do
  include ActionView::Helpers::TextHelper
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
      click_link_or_button "Back"
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

    def given_i_am_authenticated
      sign_in_system_test(user:)
    end

    def when_i_navigate_to_the_providers_onboarding_form_requests_page
      visit support_root_path
      click_link "Onboarding"
    end

    def when_i_visit_the_providers_onboarding_form_requests_page
      visit support_providers_onboarding_form_requests_path
    end

    def then_i_see_providers_onboarding_form_requests_table
      expect(page).to have_content("Provider Onboarding Requests")
      expect(page).to have_content("Id")
      expect(page).to have_content("Form name")
      expect(page).to have_content("Form link")
      expect(page).to have_content("Zendesk link")
      expect(page).to have_content("Status")
      expect(page).to have_content("Created at")
    end

    def then_i_see_recent_providers_onboarding_form_requests_entries
      ProvidersOnboardingFormRequest.order(created_at: :desc).limit(10).each do |request|
        expect(page).to have_content(request.id)
        expect(page).to have_content(request.form_name)
        expect(page).to have_link("View form", href: request.form_link)
        expect(page).to have_link("View zendesk ticket", href: request.zendesk_link).or have_content("Not available")
        expect(page).to have_content(request.support_agent.present? ? request.support_agent.name : "Unassigned")
        expect(page).to have_content(request.status.titleize)
        expect(page).to have_content(request.created_at.strftime("%d %B %Y"))
      end
    end

    def then_i_see_backlink_to_support_homepage
      expect(page).to have_link("Back", href: support_root_path)
    end

    def then_i_am_on_the_support_homepage
      expect(page).to have_current_path(support_recruitment_cycle_providers_path(Find::CycleTimetable.current_year))
    end

    def then_i_see_first_page_of_requests_with_pagination
      expect(page).to have_selector("table tbody tr", count: 10)
      expect(page).to have_link("Next")
    end

    def then_i_see_second_page_of_requests_with_pagination
      expect(page).to have_selector("table tbody tr", count: 8)
      expect(page).to have_link("Previous")
    end
  end
end
