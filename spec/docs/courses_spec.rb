require "swagger_helper"

describe "API" do
  path "/recruitment_cycles/{year}/courses" do
    get "Returns the courses for the specified recruitment cycle." do
      operationId :public_api_v1_courses
      tags "courses"
      produces "application/json"
      parameter name: :year,
        in: :path,
        type: :string,
        required: true,
        description: "The starting year of the recruitment cycle.",
        example: "2020"
      parameter name: :filter,
        in: :query,
        schema: { "$ref" => "#/components/schemas/CourseFilter" },
        type: :object,
        style: :deepObject,
        explode: true,
        required: false,
        description: "Refine courses to return.",
        example: {
          has_vacancies: true,
          subjects: "00,01",
          updated_since: "2020-11-13T11:21:55Z",
          degree_grade: "two_two",
          provider_can_sponsor_visa: true,
        }
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
          enum: %w[accredited_body provider recruitment_cycle],
        },
        example: "recruitment_cycle,provider"

      curl_example description: "Get all courses",
        command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/courses"

      curl_example description: "Get the second page of courses",
        command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/courses?page[page]=2"

      curl_example description: "Sort courses by distance from given latitude and longitude",
        command: 'curl -X GET "https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/courses?page\[per_page\]=10&filter\[latitude\]=51.8975918&filter\[longitude\]=-0.4910925&filter\[radius\]=10&sort=distance"'

      response "200", "The collection of courses." do
        let(:year) { "2020" }
        let(:include) { "provider" }

        before do
          create(:course, course_code: "C100")
        end

        schema({ "$ref": "#/components/schemas/CourseListResponse" })

        run_test!
      end
    end
  end
end
