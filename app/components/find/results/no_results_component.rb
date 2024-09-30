# frozen_string_literal: true

module Find
  module Results
    class NoResultsComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :results

      delegate :devolved_nation?, :country, :subjects, :with_salaries?, :show_undergraduate_courses?, to: :results

      def initialize(results:)
        super
        @results = results
      end

      def render?
        results.no_results_found?
      end
    end
  end
end
