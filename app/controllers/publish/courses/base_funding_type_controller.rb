# frozen_string_literal: true

module Publish
  module Courses
    class BaseFundingTypeController < ApplicationController
      include SuccessMessage
      include GotoPreview

    private

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end

      def funding_type_params
        params.require(funding_type)
              .except(:goto_preview)
              .permit(*funding_type_fields)
      end

      def formatted_params
        if funding_type_params[:course_length] == "Other" && funding_type_params[:course_length_other_length].present?
          funding_type_params.merge(
            course_length: funding_type_params[:course_length_other_length],
          )
        else
          funding_type_params
        end
      end

      def funding_type
        raise NotImplementedError
      end

      def funding_type_fields
        raise NotImplementedError
      end

      def param_form_key = funding_type
    end
  end
end
