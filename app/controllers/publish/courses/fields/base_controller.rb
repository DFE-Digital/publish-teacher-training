# frozen_string_literal: true

# Provider service namespace
module Publish
  # Module for managing courses
  module Courses
    # Module for managing course fields
    module Fields
      # Base controller for course fields
      class BaseController < ::Publish::ApplicationController
        include CopyCourseContent
        before_action :authorise_with_pundit
        before_action :redirect_to_course_if_feature_disabled

      private

        # Redirects to the course page if the long form content feature flag is not active
        def redirect_to_course_if_feature_disabled
          unless FeatureFlag.active?(:long_form_content)
            redirect_to publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code,
            )
          end
        end

        # Authorises the user with Pundit
        def authorise_with_pundit
          authorize course_to_authorise
        end

        # Fetches the course to authorise based on provider and course code
        def course_to_authorise
          @course_to_authorise ||= provider.courses.find_by!(course_code: params[:code])
        end

        # Decorates the course for use in the view
        def course
          @course ||= CourseDecorator.new(course_to_authorise)
        end

        # Fetches the course enrichment, initializing a draft if it doesn't exist
        def course_enrichment
          @course_enrichment ||= course.enrichments.find_or_initialize_draft
        end
      end
    end
  end
end
