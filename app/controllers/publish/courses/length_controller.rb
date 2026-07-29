# frozen_string_literal: true

module Publish
  module Courses
    class LengthController < ApplicationController
      before_action :redirect_if_not_editable

      def edit
        @course_length_form = CourseLengthForm.new(course_enrichment)

        @course_length_form.valid? if show_errors_on_publish?
      end

      def update
        @course_length_form = CourseLengthForm.new(course_enrichment, params: length_params)
        section_name = I18n.t("publish.providers.course_length.edit.course_length")

        if @course_length_form.invalid?
          render :edit
        elsif confirm_live_changes_if_required!(
          section_name:,
          form: @course_length_form,
          form_param_key: :publish_course_length_form,
        )
          # rendered interstitial
        elsif @course_length_form.save!
          course_updated_message section_name
          redirect_to redirect_path
        end
      end

    private

      def length_params
        params.expect(publish_course_length_form: [*CourseLengthForm::FIELDS])
      end

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end

      def redirect_if_not_editable
        return unless course.cannot_change_course_length?

        redirect_to redirect_path
      end

      def redirect_path
        publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          recruitment_cycle.year,
          course.course_code,
        )
      end
    end
  end
end
