require "swagger_helper"

describe "API" do
  path "/api/public/v4/providers" do
    get "Returns providers for the current recruitment cycle" do
      operationId :public_api_v1_providers_list
      tags "provider"
      produces "application/json"
      parameter name: :filter,
                in: :query,
                type: :object,
                style: "deepObject",
                required: false
      parameter name: :sort,
                in: :query,
                type: :object,
                style: "deepObject",
                required: false

      response "200", "The list of providers in the current recruitment cycle" do
        schema "$ref": "#/components/schemas/ProviderListResponse"
      end
    end
  end

  path "/api/public/v4/providers/:provider_code" do
    get "Returns provider resource in the current recruitment cycle" do
      operationId :public_api_v1_provider_show
      tags "provider"
      produces "application/json"
      parameter name: :filter,
                in: :query,
                type: :object,
                style: "deepObject",
                required: false
      parameter name: :sort,
                in: :query,
                type: :object,
                style: "deepObject",
                required: false

      response "200", "The provider resource in the current recruitment cycle" do
        schema "$ref": "#/components/schemas/ProviderSingleResponse"
      end
    end
  end
end
