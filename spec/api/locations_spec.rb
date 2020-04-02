require "swagger_helper"

describe "API" do
  path "/courses/{course_code}/locations" do
    get "Returns locations for the given course" do
      operationId :public_api_v1_course_locations
      tags "location"
      produces "application/json"
      parameter name: :course_code,
        in: :path,
        type: :string,
        description: "The code of the course"

      response "200", "The list of locations for the given course" do
        let(:course_code) { 123 }

        schema "$ref": "#/components/schemas/LocationsList"

        run_test!
      end
    end
  end
end
