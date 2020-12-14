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

        def jsonapi_pagination(collection)
          collection.present? && pagy_scope.present? ? pagination_links : {}
        end

      private

      # child must define pagy_scope method for paginations related items
        def pagy_scope; end

        def pagy_results
          @pagy_results ||= pagy(pagy_scope, items: per_page, page: page)
        end

        def paginated_records
          @paginated_records ||= pagy_results.second
        end

        def pagination_links
          meta = pagy_metadata(pagy_results.first, urls: true)

          {
            first: meta[:first_url],
            last: meta[:last_url],
            prev: meta[:prev].nil? ? nil : meta[:prev_url],
            next: meta[:next].nil? ? nil : meta[:next_url],
          }
        end

        def per_page
          [(per_page_parameter || default_per_page).to_i, max_per_page].min
        end

        def default_per_page
          100
        end

        def max_per_page
          500
        end

        def page
          (page_parameter || 1).to_i
        end

        def page_parameter
          return params[:page][:page] if page_is_nested?

          params[:page]
        end

        def per_page_parameter
          return params[:page][:per_page] if page_is_nested?

          params[:per_page]
        end

        def page_is_nested?
          params[:page].is_a?(ActionController::Parameters)
        end
      end
    end
  end
end
