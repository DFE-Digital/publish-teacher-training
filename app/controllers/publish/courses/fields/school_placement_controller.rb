# frozen_string_literal: true

# Provider service namespace
module Publish
  # Module for managing courses
  module Courses
    # Module for managing course fields
    module Fields
      # Controller for managing school placement fields in the course enrichment
      class SchoolPlacementController < Publish::Courses::Fields::BaseController
        include CopyCourseContent
        before_action :authorise_with_pundit

        # Page to edit school placements data that is stored in the course enrichment
        def edit
          @school_placement_form = Publish::Courses::Fields::SchoolPlacementForm.new(course_enrichment)
          @copied_fields = copy_content_check(::Courses::Copy::V2_SCHOOL_PLACEMENT_FIELDS)
          @copied_fields_values = copied_fields_values if @copied_fields.present?
          @school_placement_form.valid? if show_errors_on_publish?
        end

        # Page to update school placements data
        def update
          @school_placement_form = Publish::Courses::Fields::SchoolPlacementForm.new(
            course_enrichment,
            params: school_placement_params,
          )

          if @school_placement_form.save!
            course_updated_message CourseEnrichment.human_attribute_name("what-trainee-do-in-school-success")

            redirect_to publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code,
            )

          else
            fetch_course_list_to_copy_from
            render :edit
          end
        end

      private

        # Fetches the parameters for the school placement form
        def school_placement_params
          params.require(:publish_courses_fields_school_placement_form).permit(
            :placement_school_activities,
            :support_and_mentorship,
          )
        end
      end
    end
  end
end
