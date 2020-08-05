module API
  module Public
    module V1
      class ApplicationController < ActionController::API
        rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404

        def jsonapi_404
          render jsonapi: nil, status: :not_found
        end

      private

        def fields_param
          params.fetch(:fields, {})
            .permit(:subject_areas, :subjects, :courses, :providers)
            .to_h
            .map { |k, v| [k, v.split(",").map(&:to_sym)] }
        end
      end
    end
  end
end
