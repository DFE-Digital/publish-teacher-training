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

          if course.is_primary? && @grade_form.save(course)
            flash[:success] = I18n.t("success.saved")

            redirect_to publish_provider_recruitment_cycle_course_path
          elsif @grade_form.save(course)
            redirect_to degrees_subject_requirements_publish_provider_recruitment_cycle_course_path
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

          params.require(:publish_degree_grade_form).permit(:grade)[:grade]
        end
      end
    end
  end
end
