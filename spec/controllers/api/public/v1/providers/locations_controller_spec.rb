# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Public::V1::Providers::LocationsController do
  let(:provider) { create(:provider) }

  describe "#index" do
    context "when a provider does not have any locations" do
      before do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
        }
      end

      it "returns empty array of data" do
        expect(json_response["data"]).to eql([])
      end
    end

    context "when a provider has locations" do
      before do
        provider.sites << build_list(:site, 5, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
        }
      end

      it "returns the correct number of locations" do
        expect(json_response["data"].size).to be(5)
      end

      context "with includes" do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            include: "recruitment_cycle,provider",
          }
        end

        it "returns the requested associated data in the response" do
          relationships = json_response["data"][0]["relationships"]

          recruitment_cycle_id = relationships.dig("recruitment_cycle", "data", "id").to_i
          provider_id = relationships.dig("provider", "data", "id").to_i

          expect(json_response["data"][0]["relationships"].keys.sort).to eq(
            %w[provider recruitment_cycle],
          )

          expect(recruitment_cycle_id).to eq(provider.recruitment_cycle.id)
          expect(provider_id).to eq(provider.id)
        end
      end

      context "location count" do
        it "returns the location count in a meta object" do
          meta = json_response["meta"]

          expect(meta["count"]).to be(5)
        end
      end
    end

    context "when the provider does not exist" do
      before do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: "asdf",
        }
      end

      it "returns errors not found" do
        expect(response).to be_not_found

        expect(json_response["errors"]).to eql([{ "status" => 404, "title" => "NOT_FOUND", "detail" => "The requested resource could not be found" }])
      end
    end
  end

  describe "recruitment cycle" do
    context 'when "current" is specified as the recruitment cycle' do
      before do
        provider.sites << build_list(:site, 5, provider:)

        get :index, params: {
          recruitment_cycle_year: "current",
          provider_code: provider.provider_code,
        }
      end

      it "returns the correct number of locations" do
        expect(json_response["data"].size).to be(5)
      end
    end

    context "when a non-existent recruitment cycle is specified" do
      before do
        provider.sites << build_list(:site, 5, provider:)

        get :index, params: {
          recruitment_cycle_year: "1066",
          provider_code: provider.provider_code,
        }
      end

      it "returns locations for current recruitment year" do
        expect(json_response["data"].size).to be(5)
      end
    end
  end
end
