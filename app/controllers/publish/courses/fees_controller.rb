module Publish
  module Courses
    class FeesController < BaseFundingTypeController
      include CopyCourseContent
      decorates_assigned :source_course

      def edit
        authorize(provider)

        @course_fee_form = CourseFeeForm.new(course_enrichment)
        copy_content_check(::Courses::Copy::FEES_FIELDS)
        @course_fee_form.valid? if show_errors_on_publish?
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

      def funding_type
        :publish_course_fee_form
      end

      def funding_type_fields
        CourseFeeForm::FIELDS
      end
    end
  end
end
