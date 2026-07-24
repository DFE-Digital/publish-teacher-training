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
        previous_school_names = school_names

        if after_schools_remodel_cycle?
          update_course_and_provider_schools
        else
          update_legacy_and_provider_schools
        end

        send_notifications(previous_school_names)
      end

    private

      attr_reader :course, :params

      def update_legacy_and_provider_schools
        ActiveRecord::Base.transaction do
          UpdateCourseSiteStatusesService.new(course:, params:, send_notifications: false).call
          update_provider_schools(raise_on_missing_provider_schools: false)
        end
      end

      def update_course_and_provider_schools
        ActiveRecord::Base.transaction do
          # Saving the course here is intentionally not just about persisting
          # schools_validated. Course saves update course.changed_at and then
          # TouchProvider updates provider.changed_at; Apply watches
          # provider.changed_at to decide whether to sync provider data.
          course.assign_attributes(course_attributes)
          update_provider_schools(raise_on_missing_provider_schools: true)
          course.save! if course.has_changes_to_save?
        end
      end

      def course_attributes
        params.to_h.deep_symbolize_keys.except(:school_uuids)
      end

      def update_provider_schools(raise_on_missing_provider_schools:)
        UpdateCourseProviderSchoolsService.call(course:, params:, raise_on_missing_provider_schools:)
      end

      def send_notifications(previous_school_names)
        updated_school_names = school_names
        return if previous_school_names == updated_school_names

        if FeatureFlag.active?(:course_sites_updated_email_notification)
          NotificationService::CourseSitesUpdated.call(
            course:,
            previous_site_names: previous_school_names,
            updated_site_names: updated_school_names,
          )
        end
      end

      def school_names
        if after_schools_remodel_cycle?
          course.schools.reload.includes(:provider_school).map { |course_school| course_school.provider_school.location_name }
        else
          course.sites.reload.map(&:location_name)
        end
      end

      def after_schools_remodel_cycle?
        course.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
      end
    end
  end
end
