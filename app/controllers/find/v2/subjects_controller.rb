# frozen_string_literal: true

module Find
  module V2
    class SubjectsController < Find::ApplicationController
      include Find::FinancialIncentiveHelper

      before_action :initialize_form

      def primary
        @primary_subject_options = Subject.primary
      end

      def secondary
        @secondary_subject_options = formatted_secondary_subject_options
      end

      def submit
        if @form.valid?
          redirect_to find_v2_results_path(subjects: @form.subjects)
        elsif primary_subjects?
          @primary_subject_options = Subject.primary
          render :primary
        else
          @secondary_subject_options = formatted_secondary_subject_options
          render :secondary
        end
      end

      private

      def initialize_form
        @form = Find::V2::Subjects::Form.new(subject_params.merge(context: subject_context))
      end

      SecondarySubjectInput = Struct.new(:code, :name, :financial_info, :subject_group, keyword_init: true)

      def subject_context
        request.path.include?('/v2/primary') ? 'primary' : 'secondary'
      end

      def primary_subjects?
        request.path.include?('/v2/primary')
      end

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
        params.fetch(:find_v2_subjects_form, {}).permit(subjects: [])
      end
    end
  end
end
