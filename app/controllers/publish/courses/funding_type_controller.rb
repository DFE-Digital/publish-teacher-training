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
        @course_funding_form.clear_stash
      end

      def update
        authorize(course, :can_update_funding_type?)

        @course_funding_form = CourseFundingForm.new(@course, params: funding_type_params)

        if @course_funding_form.valid?
          redirect_to(next_path)
        else
          @errors = @course_funding_form.errors.messages
          render :edit
        end
      end

    private

      def funding_type_params
        return {} if params[:publish_course_funding_form].blank?

        params.require(:publish_course_funding_form).permit(:funding_type)
      end

      def next_path
        if @course_funding_form.funding_type_updated?
          @course_funding_form.stash
          visa_page_path
        else
          course_page_path
        end
      end

      def current_step
        :funding_type
      end

      def error_keys
        %i[funding_type program_type]
      end

      def course_values
        {
          provider_code: course.provider_code,
          recruitment_cycle_year: course.recruitment_cycle_year,
          course_code: course.course_code,
        }
      end

      def visa_page_path
        if @course_funding_form.student_visa?
          student_visa_sponsorship_publish_provider_recruitment_cycle_course_path(course_values)
        else
          skilled_worker_visa_sponsorship_publish_provider_recruitment_cycle_course_path(
            course_values,
          )
        end
      end

      def course_page_path
        details_publish_provider_recruitment_cycle_course_path(course_values)
      end
    end
  end
end
