# frozen_string_literal: true

module Publish
  module Courses
    class DesignTechnologyController < ApplicationController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      include CourseBasicDetailConcern

      def edit
        authorize(provider)

        unless param_subject_ids.include?(design_technology_subject_id)
          redirect_to(
            details_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
            ),
          )
        end
      end

      def update
        authorize(provider)

        if confirm_live_changes_if_required!(
          section_name: "Design and technology",
          form: design_technology_confirmation_form,
          form_param_key: :course,
          fields: %i[subjects_ids design_technology_ids],
          back_path: design_technology_publish_provider_recruitment_cycle_course_path(
            @course.provider_code, @course.recruitment_cycle_year, @course.course_code,
            course: { subjects_ids: params.dig(:course, :subjects_ids) }
          ),
          cancel_path: details_publish_provider_recruitment_cycle_course_path(
            @course.provider_code, @course.recruitment_cycle_year, @course.course_code
          ),
        )
          # rendered interstitial
        elsif course_subjects_form.save!
          course_updated_message("Design and technology")

          course.update(name: course.generate_name)

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
          design_technology_ids: params[:course][:design_technology_ids],
        )
      end

      def course_subjects_form
        @course_subjects_form ||= CourseSubjectsForm.new(@course, params: sorted_subject_ids)
      end

      def design_technology_confirmation_form
        Struct.new(:subjects_ids, :design_technology_ids).new(
          Array(params.dig(:course, :subjects_ids)),
          Array(params.dig(:course, :design_technology_ids)),
        )
      end

      def design_technology_subject_id
        @design_technology_subject_id ||= @course.edit_course_options[:design_technology_subjects].id
      end

      def param_subject_ids
        params.dig(:course, :subjects_ids)&.map(&:to_i) || []
      end
    end
  end
end
