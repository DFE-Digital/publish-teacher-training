# frozen_string_literal: true

require "swagger_helper"

describe "API" do
  path "/recruitment_cycles/{year}/providers/{provider_code}/locations" do
    get "Returns the locations for the specified provider." do
      operationId :public_api_v1_provider_locations
      tags "locations"
      produces "application/json"
      parameter name: :year,
                in: :path,
                type: :string,
                required: true,
                description: 'The starting year of the recruitment cycle. Also accepts "current" for the current recruitment cycle. Defaults to current recruitment cycle if invalid year (eg "1066") is provided',
                example: Find::CycleTimetable.cycle_year_for_time(Time.zone.now)
      parameter name: :provider_code,
                in: :path,
                type: :string,
                required: true,
                description: "The unique code of the provider.",
                example: "T92"
      parameter name: :include,
                in: :query,
                type: :string,
                required: false,
                description: "The associated data for this resource.",
                schema: {
                  enum: %w[recruitment_cycle provider],
                },
                example: "recruitment_cycle,provider"

      response "200", "The collection of locations for the specified provider." do
        let(:provider) { create(:provider) }
        let(:year) { provider.recruitment_cycle.year }
        let(:provider_code) { provider.provider_code }
        let(:include) { "provider" }

        schema({ '$ref': "#/components/schemas/ProviderLocationListResponse" })

        before do
          provider.sites << build_list(
            :site,
            2,
            latitude: Faker::Address.latitude,
            longitude: Faker::Address.longitude,
          )
        end

        run_test!
      end
    end
  end
end
