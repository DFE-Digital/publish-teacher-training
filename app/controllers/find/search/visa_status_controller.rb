# frozen_string_literal: true

module Find
  module Search
    class VisaStatusController < Find::ApplicationController
      include FilterParameters
      include DefaultVacancies
      include DefaultApplicationsOpen

      before_action :build_backlink_query_parameters
      helper_method :back_path

      def new
        @visa_status_form = VisaStatusForm.new(visa_status: params[:visa_status])
      end

      def create
        @visa_status_form = VisaStatusForm.new(visa_status: form_params[:visa_status], university_degree_status: form_params[:university_degree_status])

        if @visa_status_form.valid?
          if @visa_status_form.require_visa_and_does_not_have_degree?
            redirect_to find_no_degree_and_requires_visa_sponsorship_path(filter_params[:find_visa_status_form])
          else

            redirect_to find_results_path(form_params.merge(
                                          subjects: sanitised_subject_codes,
                                          has_vacancies: default_vacancies,
                                          applications_open: default_applications_open,
                                          can_sponsor_visa: form_params[:visa_status]
                                        ))
          end
        else
          render :new
        end
      end

      private

      def sanitised_subject_codes
        form_params['subjects'].compact_blank!
      end

      def form_name = :find_visa_status_form

      def back_path(backlink_params)
        if params[:age_group] == 'further_education' || (params[:find_visa_status_form] && params[:find_visa_status_form][:age_group] == 'further_education')
          find_age_groups_path(backlink_params)
        else
          find_university_degree_status_path(backlink_params)
        end
      end

      def build_backlink_query_parameters
        @backlink_query_parameters = ResultsView.new(query_parameters: request.query_parameters[:find_visa_status_form].presence || request.query_parameters)
                                                .query_parameters_with_defaults
                                                .except(:find_visa_status_form)
      end
    end
  end
end
