# frozen_string_literal: true

module Find
  module Results
    class ResultsComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :results, :courses, :search_params

      def initialize(results:, courses:, search_params:)
        super
        @results = results
        @courses = courses
        @search_params = search_params
      end
    end
  end
end
