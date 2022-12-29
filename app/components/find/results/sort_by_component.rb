module Find
  module Results
    class SortByComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :results

      def initialize(results:)
        super
        @results = results
      end

      def render?
        !results.no_results_found? && !results.provider_filter?
      end
    end
  end
end
