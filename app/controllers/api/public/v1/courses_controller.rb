module API
  module Public
    module V1
      class CoursesController < API::Public::V1::ApplicationController
        def index
          render json: {
            data: [
              {
                id: 124,
                type: "Course",
                attributes: {
                  code: "3GTY",
                  provider_code: "066",
                  age_minimum: 10,
                  age_maximum: 14,
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
