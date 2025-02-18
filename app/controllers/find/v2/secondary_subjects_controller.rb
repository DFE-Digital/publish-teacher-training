# frozen_string_literal: true

module Find
  module V2
    class SecondarySubjectsController < Find::ApplicationController
      include Find::FinancialIncentiveHelper

      before_action :initialize_form

      def index
        @secondary_subject_options = formatted_secondary_subject_options
      end

      def submit
        if @form.valid?
          redirect_to find_results_path(subjects: @form.subjects)
        else
          @secondary_subject_options = formatted_secondary_subject_options
          render :index
        end
      end

      private

      def initialize_form
        @form = Find::V2::Subjects::SecondaryForm.new(subject_params)
      end

      SecondarySubjectInput = Struct.new(:code, :name, :financial_info, :subject_group, keyword_init: true)

      def formatted_secondary_subject_options
        Subject.secondary_subjects_with_subject_groups.map do |subject|
          SecondarySubjectInput.new(
            code: subject.subject_code,
            name: subject.subject_name,
            financial_info: financial_information(subject.financial_incentive),
            subject_group: subject.subject_group.name
          )
        end
      end

      def subject_params
        params.fetch(:find_v2_subjects_secondary_form, {}).permit(subjects: [])
      end
    end
  end
end
