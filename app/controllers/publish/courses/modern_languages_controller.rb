# frozen_string_literal: true

module Publish
  module Courses
    class ModernLanguagesController < ApplicationController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      include CourseBasicDetailConcern

      def edit
        authorize(provider)

        return if param_subject_ids.include?(modern_languages_subject_id)

        redirect_to(
          details_publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      end

      def update
        authorize(provider)

        if sorted_subject_ids.include?(design_technology_subject_id.to_s)
          redirect_to(
            design_technology_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
              course: { subjects_ids: sorted_subject_ids },
            ),
          )
          return
        end

        if confirm_live_changes_if_required!(
          section_name: "Subjects",
          form: modern_languages_confirmation_form,
          form_param_key: :course,
          fields: %i[subjects_ids language_ids],
          back_path: modern_languages_publish_provider_recruitment_cycle_course_path(
            @course.provider_code, @course.recruitment_cycle_year, @course.course_code,
            course: { subjects_ids: params.dig(:course, :subjects_ids) }
          ),
          cancel_path: details_publish_provider_recruitment_cycle_course_path(
            @course.provider_code, @course.recruitment_cycle_year, @course.course_code
          ),
        )
          # rendered interstitial
        elsif course_subjects_form.save!
          course_updated_message("Subjects")
          redirect_to(
            details_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
            ),
          )
        else
          @errors = @course.errors.messages
          render :edit
        end
      end

    private

      def sorted_subject_ids
        @sorted_subject_ids ||= SortSubjectParamsService.call(
          course: @course,
          subjects_ids: params[:course][:subjects_ids],
          language_ids: params[:course][:language_ids],
        )
      end

      def course_subjects_form
        @course_subjects_form ||= CourseSubjectsForm.new(@course, params: sorted_subject_ids)
      end

      def modern_languages_confirmation_form
        Struct.new(:subjects_ids, :language_ids).new(
          Array(params.dig(:course, :subjects_ids)),
          Array(params.dig(:course, :language_ids)),
        )
      end

      def modern_languages_subject_id
        @modern_languages_subject_id ||= @course.edit_course_options[:modern_languages_subject].id
      end

      def param_subject_ids
        params.dig(:course, :subjects_ids)&.map(&:to_i) || []
      end

      def design_technology_subject_id
        @design_technology_subject_id ||= SecondarySubject.design_technology.id
      end
    end
  end
end
