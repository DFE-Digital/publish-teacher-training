require "swagger_helper"

describe "API" do
  path "/recruitment_cycles/{year}/providers" do
    get "Returns providers for the specified recruitment cycle." do
      operationId :public_api_v1_provider_index
      tags "provider"
      produces "application/json"
      parameter name: :year,
                in: :path,
                type: :string,
                required: true,
                description: "The starting year of the recruitment cycle.",
                example: "2020"
      parameter name: :sort,
                in: :query,
                schema: { "$ref" => "#/components/schemas/Sort" },
                type: :object,
                style: :form,
                explode: false,
                required: false,
                example: "name",
                description: "Field(s) to sort the providers by."
      parameter name: :filter,
                in: :query,
                schema: { "$ref" => "#/components/schemas/ProviderFilter" },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine providers to return.",
                example: { updated_since: "2020-11-13T11:21:55Z" }
      parameter name: :page,
                in: :query,
                schema: { "$ref" => "#/components/schemas/Pagination" },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                example: { page: 2, per_page: 10 },
                description: "Pagination options to navigate through the collection."
      parameter name: :include,
                in: :query,
                type: :string,
                required: false,
                description: "The associated data for this resource.",
                schema: {
                  enum: %w[recruitment_cycle],
                },
                example: "recruitment_cycle"

      curl_example description: "Get all providers",
                   command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/providers"

      curl_example description: "Get second page of providers",
                   command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/providers?page[page]=2"

      response "200", "Collection of providers." do
        let(:year) { "2020" }
        let(:include) { "recruitment_cycle" }

        schema "$ref": "#/components/schemas/ProviderListResponse"

        run_test!
      end
    end
  end

  path "/recruitment_cycles/{year}/providers/{provider_code}" do
    get "Returns the specified provider." do
      operationId :public_api_v1_provider_show
      tags "provider"
      produces "application/json"
      parameter name: :year,
                in: :path,
                type: :string,
                required: true,
                description: "The starting year of the recruitment cycle.",
                example: "2020"
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
                  enum: %w[recruitment_cycle],
                },
                example: "recruitment_cycle"

      curl_example description: "Get a specific provider",
                   command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/providers/B20"

      response "200", "The provider." do
        let(:provider) { create(:provider, provider_code: "1AT") }
        let(:year) { provider.recruitment_cycle.year }
        let(:provider_code) { provider.provider_code }
        let(:include) { nil }

        schema "$ref": "#/components/schemas/ProviderSingleResponse"

        run_test!
      end

      response "404", "The non existant provider." do
        let(:year) { "2020" }
        let(:provider_code) { "999" }
        let(:include) { nil }

        schema "$ref": "#/components/schemas/StandardErrorResponse"

        run_test!
      end
    end
  end
end
