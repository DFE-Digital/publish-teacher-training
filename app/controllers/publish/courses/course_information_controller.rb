# frozen_string_literal: true

module Publish
  module Courses
    class CourseInformationController < PublishController
      include CopyCourseContent
      include GotoPreview

      def edit
        authorize(provider)

        @course_information_form = CourseInformationForm.new(course_enrichment)
        copy_content_check(::Courses::Copy::ABOUT_FIELDS)

        @course_information_form.valid? if show_errors_on_publish?
      end

      def update
        authorize(provider)

        @course_information_form = CourseInformationForm.new(course_enrichment, params: course_information_params)

        if @course_information_form.valid? && goto_preview?
          @course_information_form.save!
          redirect_to preview_publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
        elsif @course_information_form.valid? && !goto_preview?
          @course_information_form.save!
          course_updated_message('Course information')

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

      def course_information_params
        params
          .require(param_form_key)
          .except(:goto_preview)
          .permit(
            CourseInformationForm::FIELDS
          )
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end

      def param_form_key = :publish_course_information_form
    end
  end
end
