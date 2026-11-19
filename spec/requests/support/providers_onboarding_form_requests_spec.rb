# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support onboarding form requests" do
  include DfESignInUserHelper

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  describe "PATCH /support/providers-onboarding-form-requests/:id" do
    it "rejects a submitted request" do
      onboarding_request = create(:providers_onboarding_form_request, :ready_to_onboard)

      patch support_providers_onboarding_form_request_path(onboarding_request), params: { status: "reject" }

      expect(response).to redirect_to(support_providers_onboarding_form_requests_path)
      expect(flash[:success]).to eq("#{onboarding_request.provider_name} rejected")
      expect(onboarding_request.reload).to be_rejected
    end

    it "does not let a stale rejection overwrite an onboarded request" do
      onboarding_request = create(:providers_onboarding_form_request, :ready_to_onboard)
      provider = create(:provider)
      create(:user, providers: [provider])

      allow(ProvidersOnboardingFormRequest).to receive(:find).and_wrap_original do |find, *args|
        record = find.call(*args)
        allow(record).to receive(:with_lock).and_wrap_original do |lock, *lock_args, &block|
          onboarding_request.update!(status: :onboarded, provider:)
          lock.call(*lock_args, &block)
        end
        record
      end

      patch support_providers_onboarding_form_request_path(onboarding_request), params: { status: "reject" }

      expect(response).to redirect_to(support_providers_onboarding_form_requests_path)
      expect(flash[:error]).to eq("This provider has already been onboarded")
      expect(onboarding_request.reload).to be_onboarded
      expect(onboarding_request.provider).to eq(provider)
      expect(provider.reload.users).to be_present
    end

    it "does not reject a request that already has a provider" do
      provider = create(:provider)
      onboarding_request = create(:providers_onboarding_form_request, :ready_to_onboard, provider:)

      patch support_providers_onboarding_form_request_path(onboarding_request), params: { status: "reject" }

      expect(flash[:error]).to eq("This provider has already been onboarded")
      expect(onboarding_request.reload.provider).to eq(provider)
      expect(onboarding_request).to be_submitted
    end
  end
end
