require "swagger_helper"

describe "API" do
  path "/recruitment_cycles/{year}/providers/{provider_code}/courses/{course_code}/locations" do
    get "Returns the locations for the specified course." do
      operationId :public_api_v1_provider_course_locations
      tags "locations"
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
      parameter name: :course_code,
                in: :path,
                type: :string,
                description: "The code of the course.",
                example: "X130"

      response "200", "The collection of locations for the specified course." do
        let(:course) { create(:course) }
        let(:provider) { course.provider }
        let(:year) { "2020" }
        let(:provider_code) { provider.provider_code }
        let(:course_code) { course.course_code }

        schema "$ref": "#/components/schemas/LocationListResponse"

        before do
          course.sites << build_list(
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
