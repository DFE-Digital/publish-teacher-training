module API
  module Public
    module V1
      class SubjectAreasController < API::Public::V1::ApplicationController
        def index
          render json: {
            data: [
              {
                id: "PrimarySubject",
                type: "subject_areas",
                attributes: {
                  name: "Primary",
                  typename: "PrimarySubject",
                },
              },
              {
                id: "SecondarySubject",
                type: "subject_areas",
                attributes: {
                  name: "Secondary",
                  typename: "SecondarySubject",
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
