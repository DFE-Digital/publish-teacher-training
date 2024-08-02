# frozen_string_literal: true

class UniversityDegreeStatusForm
  include ActiveModel::Model
  attr_accessor :university_degree_status
end

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
        redirect_to find_visa_status_path(filter_params[:university_degree_status_form])
      end

      def back_path; end
      helper_method :back_path
    end
  end
end
