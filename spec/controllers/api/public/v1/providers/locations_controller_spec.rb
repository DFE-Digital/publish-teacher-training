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

    context "when the new school model feature flag is active" do
      let(:provider) { create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year + 1)) }

      before do
        FeatureFlag.activate(:course_publishing_uses_new_school_model)
      end

      context "when the recruitment cycle is not after the remodel cutover year" do
        let(:provider) { create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year)) }

        before do
          provider.sites << build_list(:site, 3, provider:)

          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
          }
        end

        it "returns the legacy sites as locations" do
          expect(json_response["data"].size).to be(3)
          expect(json_response["meta"]["count"]).to be(3)
        end
      end

      context "when a provider does not have any schools" do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
          }
        end

        it "returns empty array of data" do
          expect(json_response["data"]).to eql([])
        end

        it "returns a count of zero in the meta object" do
          expect(json_response["meta"]["count"]).to be(0)
        end
      end

      context "when a provider has schools" do
        let(:school) { create(:provider_school, provider:) }

        before do
          create(:provider_school, provider:)
          create(:provider_school, provider:, site_code: "B")
          school

          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
          }
        end

        it "returns the schools as locations" do
          expect(json_response["data"].size).to be(3)
          expect(json_response["data"].map { |location| location["type"] }.uniq).to eq(%w[locations])
        end

        it "returns the school count in the meta object" do
          expect(json_response["meta"]["count"]).to be(3)
        end

        it "serializes the school's attributes from its gias school" do
          location = json_response["data"].find { |data| data["attributes"]["code"] == school.site_code }
          attributes = location["attributes"]

          expect(attributes["name"]).to eq(school.gias_school.name)
          expect(attributes["urn"]).to eq(school.gias_school.urn)
          expect(attributes["postcode"]).to eq(school.gias_school.postcode)
          expect(attributes["city"]).to eq(school.gias_school.town)
          expect(attributes["region_code"]).to eq(school.gias_school.region_code)
          expect(attributes["uuid"]).to eq(school.uuid)
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

            expect(relationships.keys.sort).to eq(%w[provider recruitment_cycle])
            expect(recruitment_cycle_id).to eq(provider.recruitment_cycle.id)
            expect(provider_id).to eq(provider.id)
          end
        end
      end

      context "when a school's gias region code differs from the api region set" do
        before do
          create(:provider_school, provider:, gias_school: create(:gias_school, region_code: :east_of_england))

          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
          }
        end

        it "maps the gias region code to the api region code" do
          expect(json_response["data"].first["attributes"]["region_code"]).to eq("eastern")
        end
      end
    end

    context "when the feature flag is disabled and the cycle is not after the remodel cutover year" do
      let(:provider) { create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year)) }

      before do
        provider.sites << build_list(:site, 3, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
        }
      end

      it "returns the legacy sites as locations" do
        expect(json_response["data"].size).to be(3)
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
