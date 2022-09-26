module Publish
  module Courses
    class StudentVisaSponsorshipController < VisaSponsorshipController
      def new
        authorize(@provider, :can_create_course?)
        @course.can_sponsor_student_visa = @provider.can_sponsor_student_visa unless @course.can_sponsor_student_visa
        return if course.is_fee_based?

        redirect_to next_step
      end

      def edit
        authorize(provider)

        @course_student_visa_sponsorship_form = CourseStudentVisaSponsorshipForm.new(@course)
      end

      def update
        authorize(provider)
        @course_student_visa_sponsorship_form = CourseStudentVisaSponsorshipForm.new(@course, params: student_visa_sponsorship_params)
        if @course_student_visa_sponsorship_form.save!
          render_visa_sponsorship_success_message

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        else
          render :edit
        end
      end

    private

      def current_step
        :can_sponsor_student_visa
      end

      def error_keys
        [:can_sponsor_student_visa]
      end

      def visa_type
        t("visa_sponsorships.student")
      end
    end
  end
end
