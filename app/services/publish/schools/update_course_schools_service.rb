# frozen_string_literal: true

module Publish
  module Schools
    # Coordinates course school updates from Publish by writing Course::School
    # and legacy SiteStatus rows from the same Provider::School UUIDs.
    # This service also updates the course and provider so that Apply syncs course changes.
    class UpdateCourseSchoolsService
      include ServicePattern

      ENQUEUE_THRESHOLD = 30

      class UnresolvedProviderSchoolsError < StandardError; end

      def self.call_or_enqueue(course:, params:)
        if Array(params[:school_uuids]).compact_blank.uniq.size > ENQUEUE_THRESHOLD
          UpdateCourseSchoolsJob.perform_async(course.id, params.to_h)
        else
          call(course:, params:)
        end
      end

      # @param course [Course] course whose school selection should be updated
      # @param params [Hash, ActionController::Parameters] course attributes and
      #   submitted Provider::School UUIDs
      # @param raise_on_missing_provider_schools [Boolean] inline requests pass
      #   true; queued requests pass false because a school may be removed while
      #   the job is waiting to run
      def initialize(course:, params:, raise_on_missing_provider_schools: true)
        @course = course
        @params = params.to_h.deep_symbolize_keys
        @submitted_school_uuids = Array(@params.fetch(:school_uuids)).compact_blank.uniq
        @raise_on_missing_provider_schools = raise_on_missing_provider_schools
      end

      def call
        previous_school_names = school_names_for_notification

        ActiveRecord::Base.transaction do
          provider_schools = resolve_provider_schools

          course.assign_attributes(course_attributes)
          update_site_statuses(provider_schools)
          update_provider_schools(provider_schools)

          # This persists schools_validated and deliberately touches the course
          # and provider. Apply watches provider.changed_at to decide whether it
          # needs to sync the provider's courses.
          course.save!
        end

        send_notifications(
          previous_school_names:,
          updated_school_names: school_names_for_notification,
        )
      end

    private

      attr_reader :course, :params, :submitted_school_uuids

      def course_attributes
        params.except(:school_uuids)
      end

      def resolve_provider_schools
        # Prevent a concurrent removal from deleting a school after resolution
        # but before both relationship writers have completed.
        provider_schools_by_uuid = course.provider.schools
          .includes(:gias_school)
          .where(uuid: submitted_school_uuids)
          .lock
          .index_by(&:uuid)

        missing_school_uuids = submitted_school_uuids - provider_schools_by_uuid.keys
        handle_missing_provider_schools(missing_school_uuids)

        submitted_school_uuids.filter_map { |uuid| provider_schools_by_uuid[uuid] }
      end

      def handle_missing_provider_schools(missing_school_uuids)
        return if missing_school_uuids.empty?

        message = "no provider_school for provider=#{course.provider.id} " \
          "school_uuids=#{missing_school_uuids.join(',')}"
        raise UnresolvedProviderSchoolsError, message if raise_on_missing_provider_schools?

        Rails.logger.warn("[CourseSchools] skipped stale provider_school UUIDs - #{message}")
      end

      def update_provider_schools(provider_schools)
        UpdateCourseProviderSchoolsService.call(
          course:,
          provider_schools:,
        )
      end

      # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
      # TODO School data remodel removal - remove this legacy write once all school reads use Course::School.
      # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
      def update_site_statuses(provider_schools)
        UpdateCourseSiteStatusesService.call(
          course:,
          school_uuids: provider_schools.map(&:uuid),
        )
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

      def school_names_for_notification
        course.schools.includes(:provider_school)
          .map { |course_school| course_school.provider_school.location_name }
          .sort
      end

      def raise_on_missing_provider_schools?
        @raise_on_missing_provider_schools
      end
    end
  end
end
