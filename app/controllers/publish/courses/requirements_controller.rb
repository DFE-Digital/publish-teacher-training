module Publish
  module Courses
    class RequirementsController < PublishController
      def edit
        authorize(provider)

        @course_requirement_form = CourseRequirementForm.new(course_enrichment)
      end

      def update
        authorize(provider)

        @course_requirement_form = CourseRequirementForm.new(course_enrichment, params: course_requirement_params)

        if @course_requirement_form.save!
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

      def course_requirement_params
        params
          .require(:publish_course_requirement_form)
          .permit(
            CourseRequirementForm::FIELDS,
          )
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end
    end
  end
end
