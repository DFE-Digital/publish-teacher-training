# frozen_string_literal: true

module Find
  module Search
    class UniversityDegreeStatusController < Find::ApplicationController
      include FilterParameters
      include DefaultVacancies
      include DefaultApplicationsOpen

      before_action :build_backlink_query_parameters
      helper_method :back_path

      def new
        @university_degree_status_form = UniversityDegreeStatusForm.new(university_degree_status: params[:university_degree_status])
      end

      def create
        @university_degree_status_form = UniversityDegreeStatusForm.new(university_degree_status: form_params[:university_degree_status])

        if @university_degree_status_form.valid?
          redirect_to find_results_path(form_params.merge(
                                          subjects: sanitised_subject_codes,
                                          has_vacancies: default_vacancies,
                                          applications_open: default_applications_open,
                                          university_degree_status: form_params[:university_degree_status]
                                        ))
        else
          render :new
        end
      end

      private

      def sanitised_subject_codes
        form_params['subjects'].compact_blank!
      end

      def form_name = :find_university_degree_status_form

      def back_path(backlink_params)
        if params[:age_group] == 'further_education' || (params[:find_university_degree_status_form] && params[:find_university_degree_status_form][:age_group] == 'further_education')
          find_age_groups_path(backlink_params)
        else
          find_subjects_path(backlink_params)
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
