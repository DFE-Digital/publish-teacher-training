module Publish
  module Courses
    class VisaSponsorshipController < PublishController
      include CourseBasicDetailConcern

      def new
        raise NotImplementedError
      end

      def edit
        authorize(provider)

        visa_sponsorship_form
      end

      def update
        authorize(provider)

        if visa_sponsorship_form.save!
          flash[:success] = success_message

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

      def visa_sponsorship_form
        @visa_sponsorship_form ||= CourseFundingForm.new(@course, params: visa_sponsorship_params)
      end

      def current_step
        raise NotImplementedError
      end

      def error_keys
        raise NotImplementedError
      end

      def visa_sponsorship_params
        return {} if params[:publish_course_funding_form].blank?

        params.require(:publish_course_funding_form).permit(CourseFundingForm::FIELDS)
      end

      def success_message
        success_message_key = visa_sponsorship_form.funding_type_updated? ? "visa_sponsorships.updated.#{visa_sponsorship_form.origin_step}_and_visa" : "visa_sponsorships.updated.visa"

        visa_type = t("visa_sponsorships.#{visa_sponsorship_form.visa_type}")
        t(success_message_key, visa_type:)
      end
    end
  end
end
