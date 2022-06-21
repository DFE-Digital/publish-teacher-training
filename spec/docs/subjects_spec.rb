require "swagger_helper"

describe "API" do
  path "/subjects" do
    get "Returns a list of subjects" do
      operationId :public_api_v1_subjects
      tags "Subjects"
      produces "application/json"
      parameter name: :sort,
        in: :query,
        schema: { "type" => "string" },
        type: :string,
        style: :form,
        explode: false,
        required: false,
        example: "name",
        description: "Sort subjects by name"

      curl_example description: "Get all subjects",
        command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/subjects"

      response "200", "The list of subjects" do
        let(:sort) { "name" }

        schema "$ref": "#/components/schemas/SubjectListResponse"

        run_test!
      end
    end
  end
end
