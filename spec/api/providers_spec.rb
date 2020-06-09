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
                description: "The starting year of the recruitment cycle."
      parameter name: :filter,
                in: :query,
                schema: { "$ref" => "#/components/schemas/Filter" },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine courses to return."
      parameter name: :sort,
                in: :query,
                schema: { "$ref" => "#/components/schemas/Sort" },
                type: :object,
                style: :form,
                explode: false,
                required: false,
                example: "provider.provider_name,name",
                description: "Field(s) to sort the courses by."
      parameter name: :page,
                in: :query,
                schema: { "$ref" => "#/components/schemas/Pagination" },
                type: :object,
                style: :form,
                explode: false,
                required: false,
                example: "page[page]=2&page[per_page]=10",
                description: "Pagination options to navigate through the collection."

      response "200", "Collection of providers." do
        let(:year) { "2020" }

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
                description: "The starting year of the recruitment cycle."
      parameter name: :provider_code,
                in: :path,
                type: :string,
                required: true,
                description: "The unique code of the provider."

      response "200", "The provider." do
        let(:year) { "2020" }
        let(:provider_code) { "ABC" }

        schema "$ref": "#/components/schemas/ProviderSingleResponse"

        run_test!
      end
    end
  end
end
