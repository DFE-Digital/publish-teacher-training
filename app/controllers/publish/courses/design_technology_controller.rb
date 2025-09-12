# frozen_string_literal: true

module Publish
  module Courses
    class DesignTechnologyController < ApplicationController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      before_action :build_course_params, only: [:continue]
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        return if has_design_technology_subject?

        redirect_to next_step
      end

      def update
        authorize(provider)

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
      #
      # def back
      #   authorize(@provider, :edit?)
      #   if has_design_technology_subject?
      #     redirect_to new_publish_provider_recruitment_cycle_courses_design_technology_path(path_params)
      #   else
      #     redirect_to @back_link_path
      #   end
      # end

      def current_step
        :design_technology
      end

    private

      def updated_subject_list
        @updated_subject_list ||= selected_non_design_technology_subjects_ids.concat(selected_design_technology_subjects_ids)
      end

      def course_subjects_form
        @course_subjects_form ||= CourseSubjectsForm.new(@course, params: updated_subject_list)
      end

      def error_keys
        [:design_technology_subjects]
      end

      def design_technology_subject_id
        @design_technology_subject_id ||= @course.edit_course_options[:design_technology_subjects].id
      end

      #       def selected_subjects(param_key)
      #   edit_course_options_key = param_key == :language_ids ? :modern_languages : :subjects

      #   ids = params.dig(:course, param_key)&.map(&:to_i) || []

      #   ids.intersection(@course.edit_course_options[edit_course_options_key].map(&:id))
      # end

      # def selected_language_subjects_ids
      #   selected_subjects(:language_ids)
      # end

      # def selected_non_language_subjects_ids
      #   selected_subjects(:subjects_ids)
      # end

      def has_design_technology_subject?
        @course.course_subjects.any? { |subject| subject.subject.id == design_technology_subject_id }
      end

      def build_course_params
        build_new_course
        params[:course][:subjects_ids] = params[:course][:design_technology_ids] if params[:course][:design_technology_ids]
        params[:course].delete(:design_technology_ids)
      end

      # def non_language_subject_ids
      #   @course.edit_course_options[:subjects].map(&:id).map(&:to_s)
      # end

      # def selected_non_language_subject_ids
      #   non_language_subject_ids & params[:course][:subjects_ids]
      # end
    end
  end
end
