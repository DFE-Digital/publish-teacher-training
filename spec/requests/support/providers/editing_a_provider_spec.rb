# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support editing a provider code" do
  include DfESignInUserHelper

  let(:provider) { create(:provider, provider_code: "Q10") }
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
  end

  describe "GET edit" do
    it "shows an editable provider code when no course has been published" do
      create(:course, provider:)

      get edit_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('name="provider[provider_code]"')
    end

    it "shows the provider code as text when a course has been published" do
      create(:course, :published, provider:)

      get edit_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('name="provider[provider_code]"')
      expect(response.body).to include("You cannot change the provider code because this provider has had a published course.")
      expect(response.body).to include(provider.provider_code)
    end

    it "shows the provider code as text when a published course has been withdrawn" do
      create(:course, :withdrawn, provider:)

      get edit_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('name="provider[provider_code]"')
    end
  end

  describe "PATCH update" do
    it "does not change the provider code when a course has been withdrawn" do
      create(:course, :withdrawn, provider:)

      patch support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider), params: {
        provider: { provider_code: "Z99", provider_name: provider.provider_name },
      }

      expect(provider.reload.provider_code).to eq("Q10")
      expect(response.body).to include("Provider code cannot be changed because this provider has had a published course")
    end

    it "still updates other details when a course has been published" do
      create(:course, :published, provider:)

      patch support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider), params: {
        provider: { provider_name: "Updated provider name" },
      }

      expect(response).to redirect_to(support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider))
      expect(provider.reload.provider_name).to eq("Updated provider name")
      expect(provider.provider_code).to eq("Q10")
    end
  end
end
