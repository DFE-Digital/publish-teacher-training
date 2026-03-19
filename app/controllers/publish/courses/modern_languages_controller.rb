# frozen_string_literal: true

module Publish
  module Courses
    class ModernLanguagesController < ApplicationController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      before_action :build_course_params, only: [:continue]
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        return if has_modern_languages_subject?

        redirect_to next_step
      end

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

        if merged_subject_ids.include?(design_technology_subject_id.to_s)
          redirect_to(
            design_technology_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
              course: { subjects_ids: merged_subject_ids },
            ),
          )
          return
        end

        if course_subjects_form.save!
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

      def back
        authorize(@provider, :edit?)
        if has_modern_languages_subject?
          redirect_to new_publish_provider_recruitment_cycle_courses_modern_languages_path(path_params)
        else
          redirect_to @back_link_path
        end
      end

      def current_step
        :modern_languages
      end

    private

      def merged_subject_ids
        @merged_subject_ids ||= MergeSubjectIdsService.call(
          course: @course,
          subjects_ids: params[:course][:subjects_ids],
          language_ids: params[:course][:language_ids],
        )
      end

      def course_subjects_form
        @course_subjects_form ||= CourseSubjectsForm.new(@course, params: merged_subject_ids)
      end

      def error_keys
        [:modern_languages_subjects]
      end

      def modern_languages_subject_id
        @modern_languages_subject_id ||= @course.edit_course_options[:modern_languages_subject].id
      end

      def has_modern_languages_subject?
        @course.course_subjects.any? { |subject| subject.subject.id == modern_languages_subject_id }
      end

      def param_subject_ids
        params.dig(:course, :subjects_ids)&.map(&:to_i) || []
      end

      def build_course_params
        build_new_course

        params[:course][:subjects_ids] = MergeSubjectIdsService.call(
          course: @course,
          subjects_ids: params[:course][:subjects_ids],
          language_ids: params[:course].delete(:language_ids),
        )
      end

      def design_technology_subject_id
        @design_technology_subject_id ||= SecondarySubject.design_technology.id
      end
    end
  end
end
