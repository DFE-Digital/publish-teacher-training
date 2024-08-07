# frozen_string_literal: true

module Find
  module Search
    class UniversityDegreeStatusController < Find::ApplicationController
      include FilterParameters
      # include DefaultVacancies
      # include DefaultApplicationsOpen

      def new
        @university_degree_status_form = UniversityDegreeStatusForm.new(
          university_degree_status: params[:university_degree_status]
        )
      end

      def create
        @university_degree_status_form = UniversityDegreeStatusForm.new(
          university_degree_status: form_params[:university_degree_status]
        )

        if @university_degree_status_form.valid?
          redirect_to find_visa_status_path(filter_params[:find_university_degree_status_form])
        else
          render :new
        end
      end

      def form_name = :find_university_degree_status_form

      def back_path; end
      helper_method :back_path
    end
  end
end
