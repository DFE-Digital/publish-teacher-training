# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      # The filter box above the provider's paginated list of schools.
      #
      # Without JavaScript it is a plain text field that GETs the schools index,
      # which does the narrowing server-side. The remote-autocomplete controller
      # enhances it with suggestions drawn from the provider's own schools, so
      # the dropdown only ever offers rows the list can be narrowed down to.
      class FilterComponent < ViewComponent::Base
        include RemoteAutocompleteHelper

        def initialize(provider:, recruitment_cycle:, results_count:, filter: nil)
          super()

          @provider = provider
          @recruitment_cycle = recruitment_cycle
          @results_count = results_count
          @filter = filter
        end

        # The list says what it was filtered by only when it has rows to show:
        # on an empty list the index's own "No schools found" message says it,
        # and repeating the term above it reads as a contradiction.
        def showing_results?
          filter.present? && results_count.positive?
        end

        def index_path
          publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year)
        end

        def suggestions_path
          filter_publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year)
        end

      private

        attr_reader :provider, :recruitment_cycle, :filter, :results_count
      end
    end
  end
end
