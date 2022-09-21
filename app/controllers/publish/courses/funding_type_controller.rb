module Publish
  module Courses
    class FundingTypeController < PublishController
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

      def edit
        authorize(course, :can_update_funding_type?)
      end

      def update
        authorize(course, :can_update_funding_type?)

        @errors = errors
        return render :edit if @errors.present?

        track_funding_type_changes

        if @course.update(course_params)
          if @funding_type_updated
            redirect_to_visa_step
          else
            redirect_to_course_page
          end
        else
          @errors = @course.errors.messages
          render :edit
        end
      end

    private

      def current_step
        raise NotImplementedError
      end

      def error_keys
        %i[funding_type program_type]
      end

      def track_funding_type_changes
        @funding_type_updated = params[:course][:funding_type] != @course.funding_type
      end

      def redirect_to_visa_step
        if course.is_fee_based?
          redirect_to student_visa_sponsorship_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
            funding_type_updated: @funding_type_updated,
            origin_step: current_step,
          )
        else
          redirect_to skilled_worker_visa_sponsorship_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
            funding_type_updated: @funding_type_updated,
            origin_step: current_step,
          )
        end
      end

      def redirect_to_course_page
        redirect_to(
          details_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
          ),
        )
      end
    end
  end
end
