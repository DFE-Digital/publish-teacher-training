module Publish
  module Courses
    class VisaSponsorshipController < PublishController
      include CourseBasicDetailConcern

      def new
        raise NotImplementedError
      end

      ## TODO: refactor all below as it same as other controller
      def edit
        authorize(provider)

        # TODO: Replace with `@funding_form`

        @visa_sponsorship_form = visa_sponsorship_form.new(@course)
      end

      def update
        authorize(provider)
        @visa_sponsorship_form = visa_sponsorship_form.new(@course, params: visa_sponsorship_params)
        if @visa_sponsorship_form.save!
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

      def visa_sponsorship_form
        raise NotImplementedError
      end

      def visa_sponsorship_form_param_key
        raise NotImplementedError
      end

      def current_step
        raise NotImplementedError
      end

      def error_keys
        raise NotImplementedError
      end

      def visa_type
        raise NotImplementedError
      end

      def visa_sponsorship_params
        return { visa_sponsorship: nil } if params[visa_sponsorship_form_param_key].blank?

        params.require(visa_sponsorship_form_param_key).except(:funding_type_updated, :origin_step).permit(*visa_sponsorship_form::FIELDS)
      end

      def funding_type_updated?
        params[visa_sponsorship_form_param_key][:funding_type_updated] == "true"
      end

      def origin_step
        params[visa_sponsorship_form_param_key][:origin_step]
      end

      def render_visa_sponsorship_success_message
        if funding_type_updated?
          flash[:success] = t("visa_sponsorships.updated.#{origin_step}_and_visa", visa_type:)
        else
          flash[:success] = t("visa_sponsorships.updated.visa", visa_type:)
        end
      end
    end
  end
end
