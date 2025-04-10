# frozen_string_literal: true

module Publish
  module Courses
    module Degrees
      class StartController < ApplicationController
        include GotoPreview

        def edit
          authorize(provider)

          @start_form = DegreeStartForm.new
          @start_form.build_from_course(course)
          @start_form.valid? if show_errors_on_publish?
        end

        def update
          authorize(provider)

          @start_form = DegreeStartForm.new(degree_grade_required: grade_required_params)
          if course.is_primary? && @start_form.valid? && !goto_preview? && @start_form.degree_grade_required.blank?
            @start_form.save!(course)
            course_updated_message("Minimum degree classification")
            redirect_to publish_provider_recruitment_cycle_course_path
          elsif course.is_primary? && @start_form.valid? && goto_preview? && @start_form.degree_grade_required.blank?
            @start_form.save!(course)
            redirect_to preview_publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
          elsif @start_form.valid? && !goto_preview? && @start_form.degree_grade_required.blank?
            @start_form.save!(course)
            redirect_to degrees_subject_requirements_publish_provider_recruitment_cycle_course_path
          elsif @start_form.valid? && goto_preview? && @start_form.degree_grade_required.blank?
            @start_form.save!(course)
            redirect_to degrees_subject_requirements_publish_provider_recruitment_cycle_course_path(goto_preview: true)
          elsif @start_form.degree_grade_required.present? && !goto_preview?
            redirect_to degrees_grade_publish_provider_recruitment_cycle_course_path
          elsif @start_form.degree_grade_required.present? && goto_preview?
            redirect_to degrees_grade_publish_provider_recruitment_cycle_course_path(goto_preview: true)
          else
            @errors = @start_form.errors.messages
            render :edit
          end
        end

      private

        def param_form_key = :publish_degree_start_form

        def course
          @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
        end

        def grade_required_params
          return if params[param_form_key].blank?

          params.require(param_form_key)
                .except(:goto_preview)
                .permit(:degree_grade_required)[:degree_grade_required]
        end
      end
    end
  end
end
