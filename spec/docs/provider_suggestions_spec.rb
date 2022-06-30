require "swagger_helper"

describe "API" do
  path "/provider_suggestions" do
    get "Returns a list of providers suggestions matching the query term." do
      operationId :public_api_v1_provider_suggestions
      tags "provider_suggestions"
      produces "application/json"
      parameter name: :query,
        in: :query,
        type: :string,
        required: true,
        description: "The provider's marketing name or code",
        example: "oxf"

      curl_example description: "Suggest providers with the specified query",
        command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/provider_suggestions?query=oxf"

      response "200", "A list of provider suggestions matching the query term" do
        let(:query) { "oxf" }

        schema({ "$ref": "#/components/schemas/ProviderSuggestionListResponse" })

        run_test!
      end

      response "400", "A bad request" do
        let(:query) { nil }

        schema({ "$ref": "#/components/schemas/400ErrorResponse" })

        run_test!
      end
    end
  end
end
