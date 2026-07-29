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

          if @start_form.invalid?
            @errors = @start_form.errors.messages
            render :edit
          elsif @start_form.degree_grade_required.present?
            redirect_to_grade_step
          elsif confirm_live_changes_if_required!(
            section_name: "Minimum degree classification",
            form: @start_form,
            form_param_key: param_form_key,
            fields: %i[degree_grade_required],
          )
            # rendered interstitial
          else
            save_and_redirect
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

        def redirect_to_grade_step
          if goto_preview?
            redirect_to degrees_grade_publish_provider_recruitment_cycle_course_path(goto_preview: true)
          else
            redirect_to degrees_grade_publish_provider_recruitment_cycle_course_path
          end
        end

        def save_and_redirect
          @start_form.save(course)

          if course.is_primary? && !goto_preview?
            course_updated_message("Minimum degree classification")
            redirect_to publish_provider_recruitment_cycle_course_path
          elsif course.is_primary? && goto_preview?
            redirect_to preview_publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
          elsif goto_preview?
            redirect_to degrees_subject_requirements_publish_provider_recruitment_cycle_course_path(goto_preview: true)
          else
            redirect_to degrees_subject_requirements_publish_provider_recruitment_cycle_course_path
          end
        end
      end
    end
  end
end
