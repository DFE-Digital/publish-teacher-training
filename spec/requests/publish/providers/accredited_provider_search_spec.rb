# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider accredited provider search", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user, :admin) }
  let(:provider) { create(:provider, :lead_school) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:accredited_provider) { create(:provider, :accredited_provider, provider_name: "UCL") }

  before { login_user(user) }

  describe "return to support" do
    it "keeps return_to=support on search back and cancel links" do
      get search_publish_provider_recruitment_cycle_accredited_providers_path(
        provider.provider_code,
        recruitment_cycle.year,
        return_to: "support",
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css(".govuk-back-link")["href"]).to eq(
        support_recruitment_cycle_provider_accredited_partnerships_path(
          recruitment_cycle.year,
          provider,
        ),
      )
      expect(response.body).to include(
        support_recruitment_cycle_provider_accredited_partnerships_path(
          recruitment_cycle.year,
          provider,
        ),
      )
      expect(response.body).to include("return_to=support")
    end

    it "keeps return_to=support on results back and cancel links" do
      post search_publish_provider_recruitment_cycle_accredited_providers_path(
        provider.provider_code,
        recruitment_cycle.year,
        return_to: "support",
      ), params: { accredited_provider_search_form: { query: accredited_provider.provider_name } }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css(".govuk-back-link")["href"]).to eq(
        search_publish_provider_recruitment_cycle_accredited_providers_path(
          provider.provider_code,
          recruitment_cycle.year,
          return_to: "support",
        ),
      )
      expect(response.body).to include(
        support_recruitment_cycle_provider_accredited_partnerships_path(
          recruitment_cycle.year,
          provider,
        ),
      )
      expect(response.body).to include("return_to=support")
    end
  end
end
