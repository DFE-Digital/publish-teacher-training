require "swagger_helper"

describe "API" do
  path "/courses" do
    get "Returns courses for the current recruitment cycle" do
      operationId :public_api_v1_courses
      tags "course"
      produces "application/json"
      parameter name: :filter,
        in: :query,
        schema: { "$ref" => "#/components/schemas/Filter" },
        style: :deepObject,
        explode: true,
        description: "Refine courses to return",
        required: false
      parameter name: :sort,
        in: :query,
        schema: { "$ref" => "#/components/schemas/Sort" },
        style: :form,
        explode: false,
        example: "provider.provider_name,name",
        description: "Field(s) to sort the courses by",
        required: false

      response "200", "The list of courses in the current recruitment cycle" do
        schema "$ref": "#/components/schemas/CourseSingleResponse"

        run_test!
      end
    end
  end
end
