module API
  module Public
    module V1
      class ApplicationController < ActionController::API
        include Pagy::Backend
        include ErrorHandlers::Pagy

        rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404

        def jsonapi_404
          render jsonapi: nil, status: :not_found
        end
      end
    end
  end
end
