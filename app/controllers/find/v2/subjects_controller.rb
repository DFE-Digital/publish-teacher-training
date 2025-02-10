# frozen_string_literal: true

module Find
  module V2
    class SubjectsController < Find::ApplicationController
      include ActionView::Helpers::NumberHelper

      before_action :initialize_form

      def primary
        @primary_subject_options = Subject.primary
      end

      def secondary
        @secondary_subject_options = formatted_secondary_subject_options
      end

      def submit_secondary
        if @form.valid?
          redirect_to find_v2_results_path(subjects: @form.subjects)
        else
          @secondary_subject_options = formatted_secondary_subject_options
          render :secondary
        end
      end

      def submit
        if @form.valid?
          redirect_to find_v2_results_path(subjects: @form.subjects)
        else
          @primary_subject_options = Subject.primary
          render :primary
        end
      end

      private

      def initialize_form
        @form = Find::V2::Subjects::PrimarySubjectsForm.new(subject_params)
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

      def financial_information(financial_incentive)
        return unless FeatureFlag.active?(:bursaries_and_scholarships_announced) && financial_incentive.present?

        scholarship = number_with_delimiter(financial_incentive.scholarship)
        bursary = number_with_delimiter(financial_incentive.bursary_amount)

        if scholarship && bursary
          "Scholarships of £#{scholarship} or bursaries of £#{bursary} are available"
        elsif scholarship
          "Scholarships of £#{scholarship} are available"
        elsif bursary
          "Bursaries of £#{bursary} available"
        end
      end

      def subject_params
        params.fetch(:find_v2_subjects_primary_subjects_form, {}).permit(subjects: [])
      end
    end
  end
end
