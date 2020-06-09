require "swagger_helper"

describe "API" do
  path "/recruitment_cycles/{year}/providers/{provider_code}/courses/{course_code}/locations" do
    get "Returns the locations for the specified course." do
      operationId :public_api_v1_provider_course_locations
      tags "location"
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
      parameter name: :course_code,
                in: :path,
                type: :string,
                description: "The code of the course."

      response "200", "The collection of locations for the specified course." do
        let(:year) { "2020" }
        let(:provider_code) { "ABC" }
        let(:course_code) { 123 }

        schema "$ref": "#/components/schemas/LocationListResponse"

        run_test!
      end
    end
  end
end
