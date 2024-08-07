# frozen_string_literal: true

module Find
  module Search
    class NoDegreeAndRequiresVisaSponsorshipController < Find::ApplicationController
      def back_path
        find_visa_status_path(backlink_params)
      end
      helper_method :back_path

    private

      def backlink_params
        ResultsView.new(
          query_parameters: request.query_parameters[:find_university_degree_status_form].presence || request.query_parameters
        )
          .query_parameters_with_defaults
          .except(:find_university_degree_status_form)
      end
    end
  end
end
