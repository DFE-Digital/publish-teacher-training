require "swagger_helper"

describe "API" do
  path "/recruitment_cycles/{year}/courses" do
    get "Returns the courses for the specified year." do
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
                schema: { "$ref" => "#/components/schemas/Filter" },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine courses to return.",
                example: { has_vacancies: true, subjects: "00,01" }
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

      response "200", "The collection of courses for the specified year." do
        let(:year) { "2020" }

        schema "$ref": "#/components/schemas/CourseListResponse"

        run_test!
      end
    end
  end
end
