# frozen_string_literal: true

module Find
  module Results
    class ResultsComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :results, :courses, :pagy

      def initialize(results:, courses:, pagy:)
        super
        @results = results
        @courses = courses
        @pagy = pagy
      end
    end
  end
end
