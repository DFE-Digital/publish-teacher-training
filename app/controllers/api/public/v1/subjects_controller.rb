module API
  module Public
    module V1
      class SubjectsController < API::Public::V1::ApplicationController
        def index
          render json: {
            data: [
              {
                "id": "1",
                "type": "Subject",
                "attributes": {
                  "name": "Primary",
                  "code": "00",
                  "bursary_amount": 9000,
                  "early_career_payments": 2000,
                  "scholarship": 1000,
                  "subject_knowledge_enhancement_course_available": true,
                },
              },
              {
                "id": "13",
                "type": "Subject",
                "attributes": {
                  "name": "Citizenship",
                  "code": "09",
                  "bursary_amount": nil,
                  "early_career_payments": nil,
                  "scholarship": nil,
                  "subject_knowledge_enhancement_course_available": nil,
                },
              },
            ],
            jsonapi: {
              version: "1.0",
            },
          }
        end
      end
    end
  end
end
