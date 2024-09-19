# frozen_string_literal: true

module Find
  module Results
    class ResultsComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :results, :courses, :filters_view

      def initialize(results:, courses:, filters_view:)
        super
        @results = results
        @courses = courses
        @filters_view = filters_view
      end
    end
  end
end
