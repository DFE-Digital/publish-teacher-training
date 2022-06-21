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
        example: Settings.current_recruitment_cycle_year
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
      parameter name: :include,
        in: :query,
        type: :string,
        required: false,
        description: "The associated data for this resource.",
        schema: {
          enum: %w[recruitment_cycle provider course location_status],
        },
        example: "recruitment_cycle,provider,course,location_status"

      curl_example description: "Get the locations of a course",
        command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/providers/B20/courses/2N22/locations"

      response "200", "The collection of locations for the specified course." do
        let(:course) { create(:course) }
        let(:provider) { course.provider }
        let(:year) { provider.recruitment_cycle.year }
        let(:provider_code) { provider.provider_code }
        let(:course_code) { course.course_code }
        let(:include) { "provider" }

        schema "$ref": "#/components/schemas/CourseLocationListResponse"

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
