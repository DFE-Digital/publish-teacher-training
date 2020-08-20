require "swagger_helper"

describe "API" do
  path "/subject_areas" do
    get "Returns a list of subject areas used to organise subjects." do
      operationId :public_api_v1_subject_areas
      tags "subject_areas"
      produces "application/json"

      curl_example description: "Get all subject areas",
                   command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/subject_areas"

      response "200", "The collection of subject areas." do
        schema "$ref": "#/components/schemas/SubjectAreaListResponse"

        run_test!
      end
    end
  end
end
