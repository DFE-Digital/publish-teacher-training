# frozen_string_literal: true

module Publish
  module Schools
    class UpdateCourseSchoolsService
      include ServicePattern

      ENQUEUE_THRESHOLD = UpdateCourseSiteStatusesService::ENQUEUE_THRESHOLD

      def self.call_or_enqueue(course:, params:)
        if Array(params[:school_uuids]).size > ENQUEUE_THRESHOLD
          UpdateCourseSchoolsJob.perform_async(course.id, params.to_h)
        else
          call(course:, params:)
        end
      end

      def initialize(course:, params:)
        @course = course
        @params = params
      end

      def call
        if after_schools_remodel_cycle?
          update_provider_schools(raise_on_missing_provider_schools: true)
        else
          update_legacy_and_provider_schools
        end
      end

    private

      attr_reader :course, :params

      def update_legacy_and_provider_schools
        previous_site_names = course.sites.map(&:location_name)

        ActiveRecord::Base.transaction do
          UpdateCourseSiteStatusesService.new(course:, params:, send_notifications: false).call
          update_provider_schools(raise_on_missing_provider_schools: false)
        end

        send_notifications(previous_site_names)
      end

      def update_provider_schools(raise_on_missing_provider_schools:)
        UpdateCourseProviderSchoolsService.call(course:, params:, raise_on_missing_provider_schools:)
      end

      def send_notifications(previous_site_names)
        updated_site_names = course.sites.reload.map(&:location_name)
        return if previous_site_names == updated_site_names

        if FeatureFlag.active?(:course_sites_updated_email_notification)
          NotificationService::CourseSitesUpdated.call(
            course:,
            previous_site_names:,
            updated_site_names:,
          )
        end
      end

      def after_schools_remodel_cycle?
        course.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
      end
    end
  end
end
