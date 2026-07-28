# frozen_string_literal: true

module Publish
  module Schools
    # Coordinates course school updates from Publish by writing Course::School
    # and legacy SiteStatus rows from the same Provider::School UUIDs.
    # This service also updates the course and provider so that Apply syncs course changes.
    class UpdateCourseSchoolsService
      include ServicePattern

      ENQUEUE_THRESHOLD = 30

      def self.call_or_enqueue(course:, params:)
        if Array(params[:school_uuids]).compact_blank.uniq.size > ENQUEUE_THRESHOLD
          UpdateCourseSchoolsJob.perform_async(course.id, params.to_h)
        else
          call(course:, params:)
        end
      end

      # @param transactional [Boolean] inline updates are atomic and strict;
      #   queued updates pass false so valid writes survive stale school UUIDs
      def initialize(course:, params:, transactional: true)
        @course = course
        @params = params.to_h.deep_symbolize_keys
        @school_uuids = Array(@params.fetch(:school_uuids)).compact_blank.uniq
        @transactional = transactional
      end

      def call
        previous_school_names = school_names_for_notification

        within_transaction do
          course.assign_attributes(course_attributes)
          update_site_statuses
          update_provider_schools

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

      attr_reader :course, :params, :school_uuids

      def course_attributes
        params.except(:school_uuids)
      end

      def update_provider_schools
        UpdateCourseProviderSchoolsService.call(
          course:,
          school_uuids:,
          raise_on_missing_provider_schools: transactional?,
        )
      end

      # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
      # TODO School data remodel removal - remove this legacy write once all school reads use Course::School.
      # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
      def update_site_statuses
        UpdateCourseSiteStatusesService.call(course:, school_uuids:)
      end

      def within_transaction(&block)
        return yield unless transactional?

        ActiveRecord::Base.transaction(&block)
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

      def transactional?
        @transactional
      end
    end
  end
end
