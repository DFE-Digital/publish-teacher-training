# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider suggestions" do
  include DfESignInUserHelper

  let(:oxford) { create(:provider, provider_name: "Oxford University", provider_code: "OXF") }
  let(:recruitment_cycle) { oxford.recruitment_cycle }
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
  end

  describe "GET /support/:year/providers" do
    it "wires the provider search field to autocomplete" do
      get support_recruitment_cycle_providers_path(recruitment_cycle.year)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-controller="remote-autocomplete"')
      expect(response.body).to include(suggest_support_recruitment_cycle_providers_path(recruitment_cycle.year))
      expect(response.body).to include('data-remote-autocomplete-format-value="provider"')
    end
  end

  describe "GET /support/:year/providers/suggest" do
    let!(:other_cycle_provider) do
      create(:provider, recruitment_cycle: create(:recruitment_cycle, :next), provider_name: "Oxford College", provider_code: "OXC")
    end

    it "returns providers in this cycle that match the query" do
      get suggest_support_recruitment_cycle_providers_path(recruitment_cycle.year), params: { query: "oxf" }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([
        { "code" => oxford.provider_code, "name" => oxford.provider_name },
      ])
      expect(response.parsed_body).not_to include(hash_including("code" => other_cycle_provider.provider_code))
    end

    it "returns nothing until three characters have been typed" do
      get suggest_support_recruitment_cycle_providers_path(recruitment_cycle.year), params: { query: "ox" }

      expect(response.parsed_body).to eq([])
    end
  end
end
