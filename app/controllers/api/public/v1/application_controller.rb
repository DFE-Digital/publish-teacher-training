module API
  module Public
    module V1
      class ApplicationController < ActionController::API
        include Pagy::Backend
        include ResponseErrorHandler

        rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404

        rescue_from Pagy::OverflowError do |_exception|
          render_json_error(status: 400, message: I18n.t("pagy.overflow"))
        end

        def jsonapi_404
          render jsonapi: nil, status: :not_found
        end

      private

        def paginate(scope)
          _pagy, paginated_records = pagy(scope, items: per_page, page: page)

          paginated_records
        end

        def per_page
          [(params[:per_page] || default_per_page).to_i, max_per_page].min
        end

        def default_per_page
          100
        end

        def max_per_page
          100
        end

        def page
          (params[:page] || 1).to_i
        end
      end
    end
  end
end
