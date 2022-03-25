module Publish
  module Courses
    class DeletionsController < PublishController
      before_action :redirect_to_courses, if: -> { course.is_published? }

      def edit
        authorize(provider)

        @course_deletion_form = CourseDeletionForm.new(course)
      end

      def destroy
        authorize(provider)

        @course_deletion_form = CourseDeletionForm.new(course, params: deletion_params)

        if @course_deletion_form.destroy!
          flash[:success] = "#{@course.name} (#{@course.course_code}) has been deleted"

          redirect_to publish_provider_recruitment_cycle_courses_path(
            provider.provider_code,
            recruitment_cycle.year,
          )
        else
          render :edit
        end
      end

    private

      def redirect_to_courses
        redirect_to publish_provider_recruitment_cycle_courses_path(
          provider.provider_code,
          course.recruitment_cycle_year,
        )
      end

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def deletion_params
        return { course_code: nil } if params[:publish_course_deletion_form].blank?

        params
          .require(:publish_course_deletion_form)
          .permit(CourseDeletionForm::FIELDS)
      end
    end
  end
end
