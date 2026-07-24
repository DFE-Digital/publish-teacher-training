# frozen_string_literal: true

module Publish
  module Schools
    class UpdateCourseSchoolsService
      include ServicePattern

      ENQUEUE_THRESHOLD = 30

      def self.call_or_enqueue(course:, params:)
        if Array(params[:school_uuids]).size > ENQUEUE_THRESHOLD
          UpdateCourseSchoolsJob.perform_async(course.id, params.to_h)
        else
          call(course:, params:)
        end
      end

      def initialize(course:, params:)
        @course = course
        @params = params.to_h.deep_symbolize_keys
      end

      def call
        previous_school_names = school_names_for_notification

        if after_schools_remodel_cycle?
          update_course_and_provider_schools
        else
          update_legacy_and_provider_schools
        end

        send_notifications(
          previous_school_names:,
          updated_school_names: school_names_for_notification(reload: true),
        )
      end

    private

      attr_reader :course, :params

      def update_legacy_and_provider_schools
        ActiveRecord::Base.transaction do
          UpdateCourseSiteStatusesService.call(course:, params: site_status_params, send_notifications: false)
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
        params.except(:school_uuids)
      end

      def update_provider_schools(raise_on_missing_provider_schools:)
        UpdateCourseProviderSchoolsService.call(
          course:,
          school_uuids: school_uuids_for_provider_school_sync,
          raise_on_missing_provider_schools:,
        )
      end

      def site_status_params
        params_with_school_uuids(default_school_uuids: current_site_uuids)
      end

      def school_uuids_for_provider_school_sync
        submitted_school_uuids(default_school_uuids: current_provider_update_uuids)
      end

      def current_provider_update_uuids
        after_schools_remodel_cycle? ? current_provider_school_uuids : current_site_uuids
      end

      def params_with_school_uuids(default_school_uuids:)
        params.merge(school_uuids: submitted_school_uuids(default_school_uuids:))
      end

      def submitted_school_uuids(default_school_uuids:)
        # Missing school_uuids means "leave the current schools unchanged";
        # an explicit nil or empty array means "remove all schools".
        return default_school_uuids unless params.key?(:school_uuids)

        Array(params[:school_uuids]).compact_blank.uniq
      end

      def send_notifications(previous_school_names:, updated_school_names:)
        return if previous_school_names == updated_school_names
        return unless FeatureFlag.active?(:course_sites_updated_email_notification)

        # The notification service still uses legacy "site" argument names.
        # Keep that contract here until the notification API is renamed.
        NotificationService::CourseSitesUpdated.call(
          course:,
          previous_site_names: previous_school_names,
          updated_site_names: updated_school_names,
        )
      end

      def school_names_for_notification(reload: false)
        if after_schools_remodel_cycle?
          course.schools.reset if reload
          course.schools.includes(:provider_school).map { |course_school| course_school.provider_school.location_name }
        else
          course.sites.reset if reload
          course.sites.map(&:location_name)
        end
      end

      def current_site_uuids
        @current_site_uuids ||= course.sites.map(&:uuid)
      end

      def current_provider_school_uuids
        @current_provider_school_uuids ||= course.schools.includes(:provider_school).map do |course_school|
          course_school.provider_school.uuid
        end
      end

      def after_schools_remodel_cycle?
        course.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
      end
    end
  end
end
