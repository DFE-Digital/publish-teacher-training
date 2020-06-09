module API
  module Public
    module V1
      class ProvidersController < API::Public::V1::ApplicationController
        def index
          render json: {
            data: [
              {
                id: 123,
                type: "Provider",
                attributes: {
                  code: "ABC",
                  name: "Some provider",
                },
              },
            ],
            jsonapi: {
              version: "1.0",
            },
          }
        end

        def show
          render json: {
            data: {
              id: 123,
              type: "Provider",
              attributes: {
                code: "ABC",
                name: "Some provider",
              },
            },
            jsonapi: {
              version: "1.0",
            },
          }
        end
      end
    end
  end
end
