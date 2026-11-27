# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support onboarding form requests" do
  include DfESignInUserHelper

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  describe "GET /support/providers-onboarding-form-requests/:id" do
    it "hides organisation changes once the provider is onboarded" do
      provider = create(:provider)
      onboarding_request = create(
        :providers_onboarding_form_request,
        :ready_to_onboard,
        status: "onboarded",
        provider:,
      )

      get support_providers_onboarding_form_request_path(onboarding_request)

      document = Capybara.string(response.body)
      expect(document).to have_content("Northshore Training")
      expect(document).to have_link("View provider form")
      expect(document).not_to have_link("Change")
      expect(document).not_to have_button("Onboard provider")
    end

    it "hides organisation changes when the request is rejected" do
      onboarding_request = create(:providers_onboarding_form_request, :ready_to_onboard, status: "rejected")

      get support_providers_onboarding_form_request_path(onboarding_request)

      document = Capybara.string(response.body)
      expect(document).not_to have_link("Change")
      expect(document).not_to have_button("Reject provider")
    end
  end

  describe "PATCH /support/providers-onboarding-form-requests/:id" do
    it "shows that the provider has already been onboarded" do
      provider = create(:provider)
      onboarding_request = create(
        :providers_onboarding_form_request,
        :ready_to_onboard,
        status: "onboarded",
        provider:,
      )

      patch support_providers_onboarding_form_request_path(onboarding_request), params: { status: "accept" }

      expect(response).to redirect_to(support_providers_onboarding_form_requests_path)
      follow_redirect!
      expect(response.body).to include("This provider has already been onboarded")
    end

    it "links a base onboard error to the onboard actions" do
      onboarding_request = create(:providers_onboarding_form_request, :ready_to_onboard, status: "pending")

      patch support_providers_onboarding_form_request_path(onboarding_request), params: { status: "accept" }

      expect(response).to have_http_status(:unprocessable_content)
      document = Capybara.string(response.body)
      expect(document).to have_link(
        "This onboarding form has not been submitted, so the provider cannot be onboarded",
        href: "#providers-onboarding-form-request-onboard-provider-field",
      )
      expect(document).to have_css("#providers-onboarding-form-request-onboard-provider-field", text: "Onboard provider")
    end

    it "rejects a submitted request" do
      onboarding_request = create(:providers_onboarding_form_request, :ready_to_onboard)

      patch support_providers_onboarding_form_request_path(onboarding_request), params: { status: "reject" }

      expect(response).to redirect_to(support_providers_onboarding_form_requests_path)
      expect(flash[:success]).to eq("#{onboarding_request.provider_name} rejected")
      expect(onboarding_request.reload).to be_rejected
    end

    it "does not reject a request that was closed before automatic onboarding" do
      onboarding_request = create(:providers_onboarding_form_request, :ready_to_onboard, status: "closed")

      patch support_providers_onboarding_form_request_path(onboarding_request), params: { status: "reject" }

      expect(flash[:error]).to eq({ message: "This provider has already been onboarded" })
      expect(onboarding_request.reload).to be_closed
    end

    it "does not reject a request that already has a provider" do
      provider = create(:provider)
      onboarding_request = create(:providers_onboarding_form_request, :ready_to_onboard, provider:)

      patch support_providers_onboarding_form_request_path(onboarding_request), params: { status: "reject" }

      expect(flash[:error]).to eq({ message: "This provider has already been onboarded" })
      expect(onboarding_request.reload.provider).to eq(provider)
      expect(onboarding_request).to be_submitted
    end
  end
end
