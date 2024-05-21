# frozen_string_literal: true

module Publish
  module Courses
    class OutcomeController < PublishController
      include CourseBasicDetailConcern

      def new
        super
      end

      def edit
        super
      end

      def update
        authorize(provider)

        @errors = errors
        return render :edit if @errors.present?

        if @course.update(course_params)
          @course.update_default_attributes_for_undergraduate_degree_with_qts

          course_updated_message('Qualification')

          redirect_to(
            details_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code
            )
          )
        else
          @errors = @course.errors.messages
          render :edit
        end
      end

      private

      def current_step
        :outcome
      end

      def errors
        params.dig(:course, :qualification) ? {} : { qualification: ['Select a qualification'] }
      end
    end
  end
end
