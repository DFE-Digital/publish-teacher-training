module Publish
  module Courses
    class DraftRolloverController < PublishController
      before_action :redirect_to_courses, if: -> { course.is_published? }

      def edit
        authorize(provider)

        @course_rollover_form = CourseRolloverForm.new(course)
      end

      def update
        authorize(provider)

        @course_rollover_form = CourseRolloverForm.new(course)
        if @course_rollover_form.save!
          RolloverProviderService.call(provider_code: params[:provider_code], course_codes: params[:code]&.split, force: true)
          flash[:success] = "Your course has been rolled over."
          redirect_to publish_provider_recruitment_cycle_course_path(
            @provider.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          )
        else
          # handle some errors?
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
    end
  end
end