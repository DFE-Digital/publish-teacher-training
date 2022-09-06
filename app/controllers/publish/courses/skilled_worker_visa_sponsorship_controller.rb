module Publish
  module Courses
    class SkilledWorkerVisaSponsorshipController < PublishController
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        @course.can_sponsor_skilled_worker_visa = @provider.can_sponsor_skilled_worker_visa
        @course_skilled_worker_visa_sponsorship_form = CourseSkilledWorkerVisaSponsorshipForm.new(@course)
        return if course.school_direct_salaried_training_programme?

        redirect_to next_step
      end

      def edit
        authorize(provider)

        @course_skilled_worker_visa_sponsorship_form = CourseSkilledWorkerVisaSponsorshipForm.new(@course)
      end

      def update
        authorize(provider)
        @course_skilled_worker_visa_sponsorship_form = CourseSkilledWorkerVisaSponsorshipForm.new(@course, params: skilled_worker_visa_sponsorship_params)
        if @course_skilled_worker_visa_sponsorship_form.save!
          course_description_success_message("skilled worker visa")

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

      def skilled_worker_visa_sponsorship_params
        return { visa_sponsorship: nil } if params[:publish_course_skilled_worker_visa_sponsorship_form].blank?

        params.require(:publish_course_skilled_worker_visa_sponsorship_form).permit(*CourseSkilledWorkerVisaSponsorshipForm::FIELDS)
      end

      def current_step
        :can_sponsor_skilled_worker_visa
      end

      def error_keys
        [:can_sponsor_skilled_worker_visa]
      end
    end
  end
end
