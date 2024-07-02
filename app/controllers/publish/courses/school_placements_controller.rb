# frozen_string_literal: true

module Publish
  module Courses
    class SchoolPlacementsController < PublishController
      include CopyCourseContent
      include GotoPreview

      before_action :authorise_with_pundit

      def index
        @course = course
      end

      def edit
        @course_school_placements_form = CourseSchoolPlacementsForm.new(course_enrichment)
        @copied_fields = copy_content_check(::Courses::Copy::SCHOOL_PLACEMENTS_FIELDS)

        @copied_fields_values = copied_fields_values if @copied_fields.present?

        @course_school_placements_form.valid? if show_errors_on_publish?
      end

      def update
        @course_school_placements_form = CourseSchoolPlacementsForm.new(
          course_enrichment,
          params: school_placements_params
        )

        if @course_school_placements_form.valid?
          @course_school_placements_form.save!
          course_updated_message(CourseEnrichment.human_attribute_name('how_school_placements_work')) unless goto_preview?

          redirect_to preview_or_course_description
        else
          fetch_course_list_to_copy_from
          render :edit
        end
      end

      private

      def course_to_authorise
        @course_to_authorise ||= provider.courses.find_by!(course_code: params[:code])
      end

      def course
        @course ||= CourseDecorator.new(course_to_authorise)
      end

      def authorise_with_pundit
        authorize course_to_authorise
      end

      def school_placements_params
        params.require(param_form_key)
              .except(:goto_preview)
              .permit(CourseSchoolPlacementsForm::FIELDS)
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end

      def param_form_key = :publish_course_school_placements_form

      def course_information
        @course_information ||= Configs::CourseInformation.new(@course)
      end

      def preview_or_course_description
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

      def show_scitt_guidance?
        course_information.show_placement_guidance?(:program_type)
      end

      def show_universities_guidance?
        course_information.show_placement_guidance?(:provider_type)
      end
      helper_method :show_scitt_guidance?, :show_universities_guidance?
    end
  end
end
