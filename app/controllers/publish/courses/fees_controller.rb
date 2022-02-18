module Publish
  module Courses
    class FeesController < PublishController
      def edit
        authorize(provider)

        @course_fee_form = CourseFeeForm.new(course_enrichment)
      end

      def update
        authorize(provider)

        @course_fee_form = CourseFeeForm.new(course_enrichment, params: formatted_params)

        if @course_fee_form.save!
          flash[:success] = I18n.t("success.saved")

          redirect_to publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        else
          render :edit
        end
      end

    private

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def course_fee_params
        params.require(:publish_course_fee_form).permit(CourseFeeForm::FIELDS)
      end

      def formatted_params
        if course_fee_params[:course_length] == "Other" && course_fee_params[:course_length_other_length].present?
          course_fee_params.merge(
            course_length: course_fee_params[:course_length_other_length],
          )
        else
          course_fee_params
        end
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end
    end
  end
end
