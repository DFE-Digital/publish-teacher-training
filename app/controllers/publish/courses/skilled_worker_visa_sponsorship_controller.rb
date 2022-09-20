module Publish
  module Courses
    class SkilledWorkerVisaSponsorshipController < PublishController
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        @course.can_sponsor_skilled_worker_visa = @provider.can_sponsor_skilled_worker_visa unless @course.can_sponsor_skilled_worker_visa
        return if course.school_direct_salaried_training_programme? || course.pg_teaching_apprenticeship?

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

      def skilled_worker_visa_sponsorship_params
        return { visa_sponsorship: nil } if params[:publish_course_skilled_worker_visa_sponsorship_form].blank?

        params.require(:publish_course_skilled_worker_visa_sponsorship_form).except(:funding_type_updated).permit(*CourseSkilledWorkerVisaSponsorshipForm::FIELDS)
      end

      def funding_type_updated?
        params[:publish_course_skilled_worker_visa_sponsorship_form][:funding_type_updated] == "true"
      end

      def render_visa_sponsorship_success_message
        if funding_type_updated?
          flash[:success] = t("visa_sponsorships.funding_and_visa_updated", visa_type: t("visa_sponsorships.skilled_worker"))
        else
          flash[:success] = t("visa_sponsorships.visa_updated", visa_type: t("visa_sponsorships.skilled_worker"))
        end
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
