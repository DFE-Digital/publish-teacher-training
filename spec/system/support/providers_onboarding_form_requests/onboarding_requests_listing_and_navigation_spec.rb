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
    end
  end

  scenario "the requests table shows the support status labels" do
    labels = {
      "pending" => "Sent",
      "submitted" => "Ready for review",
      "closed" => "Onboarded",
      "rejected" => "Rejected",
    }
    requests = labels.map do |status, label|
      request = create(:providers_onboarding_form_request, form_name: "#{label} form")
      request.update_column(:status, status)
      request
    end

    when_i_visit_the_providers_onboarding_form_requests_page

    requests.each do |request|
      within("tr", text: request.form_name) do
        expect(page).to have_content(labels.fetch(request.status))
      end
    end
  end
end
