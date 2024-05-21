# frozen_string_literal: true

module Publish
  module Courses
    class LengthController < PublishController
      before_action :redirect_if_not_editable

      def edit
        authorize(provider)

        @course_length_form = CourseLengthForm.new(course_enrichment)

        @course_length_form.valid? if show_errors_on_publish?
      end

      def update
        authorize(provider)

        @course_length_form = CourseLengthForm.new(course_enrichment, params: length_params)

        if @course_length_form.save!
          course_updated_message I18n.t('publish.providers.course_length.edit.course_length')

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

      def length_params
        params.require(:publish_course_length_form)
              .permit(*CourseLengthForm::FIELDS)
      end

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end

      def redirect_if_not_editable
        return unless course.cannot_change_course_length?

        redirect_to publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          recruitment_cycle.year,
          course.course_code
        )
      end
    end
  end
end
