require "swagger_helper"

describe "API" do
  path "/subject_areas" do
    get "Returns a list of subject areas used to organise subjects." do
      operationId :public_api_v1_subject_areas
      tags "subject_areas"
      produces "application/json"
      parameter name: :include,
                in: :query,
                type: :string,
                required: false,
                description: "The associated data for this resource.",
                schema: { enum: %w[subjects] },
                example: "subjects"

      curl_example description: "Get all subject areas",
                   command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/subject_areas"

      response "200", "The collection of subject areas." do
        let(:include) { nil }

        schema "$ref": "#/components/schemas/SubjectAreaListResponse"

        run_test!
      end
    end
  end
end
