# frozen_string_literal: true

module Find
  module V2
    class PrimarySubjectsController < Find::ApplicationController
      include Find::FinancialIncentiveHelper

      before_action :initialize_form

      def index
        @primary_subject_options = Subject.primary
      end

      def submit
        if @form.valid?
          redirect_to find_v2_results_path(subjects: @form.subjects)
        else
          @primary_subject_options = Subject.primary
          render :index
        end
      end

      private

      def initialize_form
        @form = Find::V2::Subjects::PrimaryForm.new(subject_params)
      end

      def subject_params
        params.fetch(:find_v2_subjects_primary_form, {}).permit(subjects: [])
      end
    end
  end
end
