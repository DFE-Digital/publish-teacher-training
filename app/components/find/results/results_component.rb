module Find
  module Results
    class ResultsComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :results, :courses

      def initialize(results:, courses:)
        super
        @results = results
        @courses = courses
      end
    end
  end
end
