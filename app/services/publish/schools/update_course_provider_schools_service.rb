# frozen_string_literal: true

module Publish
  module Schools
    # Syncs Course::School rows for submitted Provider::School UUIDs.
    # The orchestrator decides whether unresolved UUIDs fail the update or are
    # logged and skipped when a queued update contains a school removed since submission.
    class UpdateCourseProviderSchoolsService
      include ServicePattern

      class UnresolvedProviderSchoolsError < StandardError; end

      # @param course [Course] course whose Course::School rows should be synced
      # @param school_uuids [Array<String>] submitted Provider::School UUIDs
      # @param raise_on_missing_provider_schools [Boolean] when true, unresolved
      #   UUIDs fail the update; when false, unresolved UUIDs are logged and the
      #   service syncs any Provider::School rows it can still resolve
      def initialize(course:, school_uuids:, raise_on_missing_provider_schools: true)
        @course = course
        @submitted_school_uuids = Array(school_uuids).compact_blank.uniq
        @raise_on_missing_provider_schools = raise_on_missing_provider_schools
      end

      def call
        handle_missing_provider_schools
        return if provider_school_ids_to_attach.empty? && provider_school_ids_to_remove.empty?

        provider_schools_to_attach.each { |provider_school| attach_provider_school(provider_school) }
        course.schools.where(provider_school_id: provider_school_ids_to_remove).destroy_all
        course.schools.reload
      end

    private

      attr_reader :course, :submitted_school_uuids

      def attach_provider_school(provider_school)
        course.schools.create_or_find_by!(provider_school:) do |course_school|
          course_school.gias_school = provider_school.gias_school
        end
      end

      def provider_school_ids_by_uuid
        @provider_school_ids_by_uuid ||= course.provider.schools
          .where(uuid: submitted_school_uuids)
          .pluck(:uuid, :id)
          .to_h
      end

      def handle_missing_provider_schools
        return if missing_provider_school_uuids.empty?

        message = "no provider_school for provider=#{course.provider.id} " \
          "school_uuids=#{missing_provider_school_uuids.join(',')}"
        raise UnresolvedProviderSchoolsError, message if raise_on_missing_provider_schools?

        Rails.logger.warn("[CourseSchools] skipped stale provider_school UUIDs - #{message}")
      end

      def missing_provider_school_uuids
        @missing_provider_school_uuids ||= submitted_school_uuids - provider_school_ids_by_uuid.keys
      end

      def submitted_provider_school_ids
        @submitted_provider_school_ids ||= provider_school_ids_by_uuid.values
      end

      def current_provider_school_ids
        @current_provider_school_ids ||= course.schools.pluck(:provider_school_id)
      end

      def provider_school_ids_to_attach
        @provider_school_ids_to_attach ||= submitted_provider_school_ids - current_provider_school_ids
      end

      def provider_school_ids_to_remove
        @provider_school_ids_to_remove ||= current_provider_school_ids - submitted_provider_school_ids
      end

      def provider_schools_to_attach
        @provider_schools_to_attach ||= course.provider.schools
          .includes(:gias_school)
          .where(id: provider_school_ids_to_attach)
      end

      def raise_on_missing_provider_schools?
        @raise_on_missing_provider_schools
      end
    end
  end
end
