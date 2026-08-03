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
      def initialize(course:, params:)
        @course = course
        @params = params.to_h.deep_symbolize_keys
        @submitted_school_uuids = Array(@params.fetch(:school_uuids)).compact_blank.uniq
      end

      def call
        previous_school_names = school_names_for_notification
        previous_provider_school_ids = provider_school_ids

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

        updated_school_names = school_names_for_notification
        refresh_last_published_at_if_schools_changed(
          previous_provider_school_ids:,
          updated_provider_school_ids: provider_school_ids,
        )
        send_notifications(
          previous_school_names:,
          updated_school_names:,
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

      def refresh_last_published_at_if_schools_changed(previous_provider_school_ids:, updated_provider_school_ids:)
        return if previous_provider_school_ids == updated_provider_school_ids

        course.refresh_last_published_at!
      end

      def handle_missing_provider_schools(missing_school_uuids)
        return if missing_school_uuids.empty?

        message = "no provider_school for provider=#{course.provider.id} " \
          "school_uuids=#{missing_school_uuids.join(',')}"
        raise UnresolvedProviderSchoolsError, message
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

      def provider_school_ids
        course.schools.pluck(:provider_school_id).sort
      end

    end
  end
end
