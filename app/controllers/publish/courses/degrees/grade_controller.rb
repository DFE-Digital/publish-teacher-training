# frozen_string_literal: true

module Publish
  module Courses
    module Degrees
      class GradeController < ApplicationController
        include GotoPreview

        def edit
          authorize(provider)

          @grade_form = DegreeGradeForm.build_from_course(course)
        end

        def update
          authorize(provider)
          course

          @grade_form = DegreeGradeForm.new(grade: grade_params)

          if @grade_form.invalid?
            @errors = @grade_form.errors.messages
            render :edit
          elsif confirm_live_changes_if_required!(
            section_name: "Minimum degree classification",
            form: @grade_form,
            form_param_key: param_form_key,
            fields: %i[grade],
          )
            # rendered interstitial
          else
            save_and_redirect
          end
        end

      private

        def course
          @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
        end

        def grade_params
          return if params[param_form_key].blank?

          params.require(param_form_key)
                .except(:goto_preview)
                .permit(:grade)[:grade]
        end

        def param_form_key = :publish_degree_grade_form

        def save_and_redirect
          @grade_form.save(course)

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
