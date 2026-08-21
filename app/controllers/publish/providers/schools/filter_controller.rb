# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      # Suggestions for the filter box above the provider's list of schools.
      #
      # Scoped to the schools the provider has already added, so every
      # suggestion is a row the filter can actually narrow the list down to.
      class FilterController < ApplicationController
        MIN_QUERY_LENGTH = 3
        LIMIT = 15

        def index
          return head :bad_request if query.to_s.length < MIN_QUERY_LENGTH

          render json: suggestions
        end

      private

        def suggestions
          provider
            .schools
            .filtered_by(query)
            .ordered_by_name
            .limit(LIMIT)
            .map { |school| { name: school.location_name, town: school.town, postcode: school.postcode } }
        end

        # `query` rather than `filter`: this is the shared remote-autocomplete
        # controller's parameter, the same one api/school_suggestions answers to.
        # The list's own narrowing is `filter` - see SchoolsController#index.
        def query
          params[:query]
        end
      end
    end
  end
end
