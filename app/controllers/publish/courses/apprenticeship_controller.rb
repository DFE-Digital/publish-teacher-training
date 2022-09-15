module Publish
  module Courses
    class ApprenticeshipController < PublishController
      include CourseBasicDetailConcern

      def continue
        authorize(@provider, :can_create_course?)
        @errors = errors
        if @errors.any?
          render :new
        elsif params[:goto_visa]
          if course.is_fee_based?
            redirect_to new_publish_provider_recruitment_cycle_courses_student_visa_sponsorship_path(path_params)
          else
            redirect_to new_publish_provider_recruitment_cycle_courses_skilled_worker_visa_sponsorship_path(path_params)
          end
        else
          redirect_to next_step
        end
      end

    private

      def current_step
        :apprenticeship
      end

      def error_keys
        %i[funding_type program_type]
      end
    end
  end
end
