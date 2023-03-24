# frozen_string_literal: true

module Publish
  module Courses
    module Degrees
      class GradeController < PublishController
        def edit
          authorize(provider)

          @grade_form = DegreeGradeForm.build_from_course(course)
        end

        def update
          authorize(provider)

          @grade_form = DegreeGradeForm.new(grade: grade_params)

          if course.is_primary? && @grade_form.valid? && !goto_preview?
            @grade_form.save(course)
            course_updated_message('Minimum degree classification')

            redirect_to publish_provider_recruitment_cycle_course_path

          elsif course.is_primary? && @grade_form.valid? && goto_preview?
            @grade_form.save(course)
            redirect_to preview_publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
          elsif @grade_form.valid? && !goto_preview?
            @grade_form.save(course)
            redirect_to degrees_subject_requirements_publish_provider_recruitment_cycle_course_path
          elsif @grade_form.valid? && goto_preview?
            @grade_form.save(course)
            redirect_to degrees_subject_requirements_publish_provider_recruitment_cycle_course_path(goto_preview: true)
          else
            @errors = @grade_form.errors.messages
            render :edit
          end
        end

        private

        def course
          @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
        end

        def grade_params
          return if params[:publish_degree_grade_form].blank?

          params.require(:publish_degree_grade_form)
                .except(:goto_preview)
                .permit(:grade)[:grade]
        end

        def goto_preview? = params.dig(:publish_degree_grade_form, :goto_preview) == 'true'
      end
    end
  end
end
