require "swagger_helper"

describe "API" do
  path "/courses" do
    get "Returns courses for the current recruitment cycle" do
      operationId :public_api_v1_courses
      tags "course"
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

      response "200", "The list of courses in the current recruitment cycle" do
        schema "$ref": "#/components/schemas/CourseSingleResponse"

        run_test!
      end
    end
  end
end
