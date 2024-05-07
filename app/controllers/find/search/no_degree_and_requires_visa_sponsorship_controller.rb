# frozen_string_literal: true

module Find
  module Search
    class NoDegreeAndRequiresVisaSponsorshipController < Find::ApplicationController
      include FilterParameters
      include DefaultVacancies
      include DefaultApplicationsOpen

      before_action :build_backlink_query_parameters
      helper_method :back_path

      private

      def back_path(backlink_params)
        if params[:age_group] == 'further_education' || (params[:find_university_degree_status_form] && params[:find_university_degree_status_form][:age_group] == 'further_education')
          find_age_groups_path(backlink_params)
        else
          find_visa_status_path(backlink_params)
        end
      end

      def build_backlink_query_parameters
        @backlink_query_parameters = ResultsView.new(query_parameters: request.query_parameters[:find_university_degree_status_form].presence || request.query_parameters)
                                                .query_parameters_with_defaults
                                                .except(:find_university_degree_status_form)
      end
    end
  end
end
