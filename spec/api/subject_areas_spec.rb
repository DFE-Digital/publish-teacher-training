require "swagger_helper"

describe "API" do
  path "/subject_areas" do
    get "Returns a list of subject areas used to organise subjects." do
      operationId :public_api_v1_subject_areas
      tags "subject_areas"
      produces "application/json"

      response "200", "The collection of subject areas." do
        schema "$ref": "#/components/schemas/SubjectAreaListResponse"

        run_test!
      end
    end
  end
end
