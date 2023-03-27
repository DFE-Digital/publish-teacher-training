# frozen_string_literal: true

module Publish
  module Courses
    class GcseRequirementsController < PublishController
      include CopyCourseContent
      decorates_assigned :source_course

      def edit
        authorize(provider)

        @gcse_requirements_form = GcseRequirementsForm.build_from_course(course)
        copy_boolean_check(::Courses::Copy::GCSE_FIELDS)
        @gcse_requirements_form.valid? if show_errors_on_publish?
      end

      def update
        authorize(provider)

        @gcse_requirements_form = GcseRequirementsForm.new(**gcse_requirements_form_params.merge(level: course.level))

        if @gcse_requirements_form.valid? && goto_preview?
          @gcse_requirements_form.save(course)
          redirect_to preview_publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
        elsif @gcse_requirements_form.valid? && !goto_preview?
          course_updated_message('GCSE requirements')
          @gcse_requirements_form.save(course)
          redirect_to publish_provider_recruitment_cycle_course_path
        else
          @errors = @gcse_requirements_form.errors.messages
          render :edit
        end
      end

      private

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def translatable_params
        %i[accept_pending_gcse
           accept_gcse_equivalency
           accept_english_gcse_equivalency
           accept_maths_gcse_equivalency
           accept_science_gcse_equivalency]
      end

      def gcse_requirements_form_params
        translatable_params.index_with do |key|
          translate_params(publish_gcse_requirements_form_params[key])
        end.merge(additional_gcse_equivalencies: helpers.raw(publish_gcse_requirements_form_params[:additional_gcse_equivalencies]))
      end

      def publish_gcse_requirements_form_params
        @publish_gcse_requirements_form_params ||= params
                                                   .require(:publish_gcse_requirements_form)
                                                   .except(:goto_preview)
                                                   .permit(
                                                     :accept_pending_gcse,
                                                     :accept_english_gcse_equivalency,
                                                     :accept_gcse_equivalency,
                                                     { accept_english_gcse_equivalency: [] },
                                                     { accept_maths_gcse_equivalency: [] },
                                                     { accept_science_gcse_equivalency: [] },
                                                     :additional_gcse_equivalencies
                                                   )
      end

      def translate_params(value)
        return if value.blank?

        if value.is_a?(Array)
          %w[Maths English Science].intersect?(value)
        else
          value == 'true'
        end
      end

      def goto_preview? = params.dig(:publish_gcse_requirements_form, :goto_preview) == 'true'
    end
  end
end
