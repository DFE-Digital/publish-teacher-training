# frozen_string_literal: true

module Publish
  module Courses
    class AboutThisCourseController < PublishController
      include GotoPreview
      include CopyCourseContent
      before_action :authorise_with_pundit

      def edit
        @about_this_course_form = CourseAboutThisCourseForm.new(course_enrichment)
        @copied_fields = copy_content_check(::Courses::Copy::ABOUT_THIS_COURSE_FIELDS)

        @copied_fields_values = copied_fields_values if @copied_fields.present?

        @about_this_course_form.valid? if show_errors_on_publish?
      end

      def update
        @about_this_course_form = CourseAboutThisCourseForm.new(course_enrichment, params: about_params)

        if @about_this_course_form.save!
          course_updated_message I18n.t('publish.providers.about_course.edit.about_this_course') unless goto_preview?

          redirect_to redirect_path
        else
          render :edit
        end
      end

      private

      def authorise_with_pundit
        authorize provider
      end

      def about_params
        params.require(param_form_key)
              .except(:goto_preview)
              .permit(*CourseAboutThisCourseForm::FIELDS)
      end

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end

      def redirect_path
        if goto_preview?
          preview_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          )
        else
          publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          )
        end
      end

      def param_form_key
        :publish_course_about_this_course_form
      end
    end
  end
end
