# frozen_string_literal: true

module Find
  module Search
    class SubjectsController < Find::ApplicationController
      include FilterParameters
      include DefaultVacancies
      include DefaultApplicationsOpen
      before_action :build_backlink_query_parameters

      def new
        @subjects_form = SubjectsForm.new(subjects: params[:subjects], age_group: params[:age_group])
      end

      def create
        @subjects_form = SubjectsForm.new(subjects: sanitised_subject_codes, age_group: form_params[:age_group])

        if @subjects_form.valid?
          redirect_to next_page
        else
          render :new
        end
      end

      private

      def next_page
        if teacher_degree_apprenticeship_active?
          find_university_degree_status_path(filter_params[:find_subjects_form])
        else
          find_visa_status_path(filter_params[:find_subjects_form])
        end
      end

      def sanitised_subject_codes
        form_params['subjects'].compact_blank!
      end

      def form_name = :find_subjects_form

      def build_backlink_query_parameters
        @backlink_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
                                                .query_parameters_with_defaults
                                                .except(:find_subjects_form)
      end
    end
  end
end
