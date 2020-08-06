module API
  module Public
    module V1
      class ProviderSuggestionsController < API::Public::V1::ApplicationController
        def index
          return render(status: :bad_request) if params[:query].nil? || params[:query].length < 3

          render json: {
            data: [
              {
                id: "O66",
                type: "Oxford Brookes University",
              },
              {
                id: "1DE",
                type: "Oxfordshire Teacher Training",
              },
              {
                id: "O33",
                type: "Oxford University",
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
