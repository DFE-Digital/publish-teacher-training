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
          redirect_to(next_step)
        end
      end

      def edit
        authorize(course, :can_update_funding_type?)
        @course_funding_form = CourseFundingForm.new(@course)
      end

      def update
        authorize(course, :can_update_funding_type?)

        track_funding_type_changes

        @course_funding_form = CourseFundingForm.new(@course, params: course_params)

        if @course_funding_form.valid?
          if @funding_type_updated
            @course_funding_form.stash
            redirect_to(visa_step_path)
          else

            redirect_to(course_page_path)
          end
        else
          @errors = @course_funding_form.errors.messages
          render :edit
        end
      end

    private

      def current_step
        :funding_type
      end

      def error_keys
        %i[funding_type program_type]
      end

      def track_funding_type_changes
        @funding_type_updated = params[:course][:funding_type] != @course.funding_type
      end

      def visa_step_path_values
        {
          provider_code: course.provider_code,
          recruitment_cycle_year: course.recruitment_cycle_year,
          course_code: course.course_code,
          funding_type_updated: @funding_type_updated,
          origin_step: current_step,
        }
      end

      def visa_step_path
        if course.is_fee_based?
          student_visa_sponsorship_publish_provider_recruitment_cycle_course_path(visa_step_path_values)
        else
          skilled_worker_visa_sponsorship_publish_provider_recruitment_cycle_course_path(
            visa_step_path_values,
          )
        end
      end

      def course_page_path
        details_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code,
        )
      end
    end
  end
end
