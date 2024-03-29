# frozen_string_literal: true

module Publish
  module Courses
    class RequirementsController < PublishController
      include CopyCourseContent
      decorates_assigned :source_course

      def edit
        authorize(provider)

        @course_requirement_form = CourseRequirementForm.new(course_enrichment)
        @copied_fields = if @course.recruitment_cycle_year.to_i >= Provider::CHANGES_INTRODUCED_IN_2022_CYCLE
                           copy_content_check(::Courses::Copy::POST_2022_CYCLE_REQUIREMENTS_FIELDS)
                         else
                           copy_content_check(::Courses::Copy::PRE_2022_CYCLE_REQUIREMENTS_FIELDS)
                         end
        @copied_fields_values = copied_fields_values if @copied_fields.present?
      end

      def update
        authorize(provider)

        @course_requirement_form = CourseRequirementForm.new(course_enrichment, params: course_requirement_params)

        if @course_requirement_form.save!
          course_updated_message('Personal qualities and other requirements')

          redirect_to publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
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
            CourseRequirementForm::FIELDS
          )
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end
    end
  end
end
