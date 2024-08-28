# frozen_string_literal: true

module Find
  module Results
    class NoResultsComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :results, :filters_view

      delegate :devolved_nation?, :country, :subjects, :with_salaries?, to: :results

      def initialize(results:, filters_view:)
        super
        @results = results
        @filters_view = filters_view
      end

      def render?
        results.no_results_found?
      end
    end
  end
end
