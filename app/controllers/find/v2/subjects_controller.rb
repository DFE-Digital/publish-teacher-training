# frozen_string_literal: true

module Find
  module V2
    class SubjectsController < Find::ApplicationController
      def primary
        @form = Find::V2::Subjects::PrimarySubjectsForm.new(subject_params)
        @primary_subject_options = Subject.primary
      end

      def submit
        @form = Find::V2::Subjects::PrimarySubjectsForm.new(subject_params)

        if @form.valid?
          redirect_to find_v2_results_path({ subjects: @form.subjects }.merge(tracking_params))
        else
          @primary_subject_options = Subject.primary
          render :primary
        end
      end

      private

      def subject_params
        params.fetch(:find_v2_subjects_primary_subjects_form, {}).permit(subjects: [])
      end

      def tracking_params
        params.fetch(:find_v2_subjects_primary_subjects_form, {}).permit(:utm_source, :utm_medium)
      end
    end
  end
end
