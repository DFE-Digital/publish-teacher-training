module FindInterface
  module Results
    class SuggestedSearchesComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :results

      def initialize(results:)
        super
        @results = results
      end

      def render?
        results.suggested_search_visible?
      end
    end
  end
end
