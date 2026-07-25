# frozen_string_literal: true

module Publish
  module Schools
    # Creates and/or removed Course:School from a course
    class UpdateCourseProviderSchoolsService
      include ServicePattern

      class UnresolvedProviderSchoolsError < StandardError; end

      def initialize(course:, school_uuids:, raise_on_missing_provider_schools: false)
        @course = course
        @submitted_school_uuids = Array(school_uuids).compact_blank.uniq
        @raise_on_missing_provider_schools = raise_on_missing_provider_schools
      end

      def call
        return unless all_submitted_provider_schools_resolved?
        return if provider_school_ids_to_attach.empty? && provider_school_ids_to_remove.empty?

        ActiveRecord::Base.transaction do
          provider_schools_to_attach.each { |provider_school| attach_provider_school(provider_school) }
          course.schools.where(provider_school_id: provider_school_ids_to_remove).destroy_all
          course.schools.reload
        end
      end

    private

      attr_reader :course, :submitted_school_uuids

      def attach_provider_school(provider_school)
        course.schools.create!(
          provider_school:,
          gias_school: provider_school.gias_school,
        )
      end

      def provider_school_ids_by_uuid
        @provider_school_ids_by_uuid ||= course.provider.schools
          .where(uuid: submitted_school_uuids)
          .pluck(:uuid, :id)
          .to_h
      end

      def all_submitted_provider_schools_resolved?
        return true if missing_provider_school_uuids.empty?

        message = "no provider_school for provider=#{course.provider.id} " \
          "school_uuids=#{missing_provider_school_uuids.join(',')}"
        raise UnresolvedProviderSchoolsError, message if raise_on_missing_provider_schools?

        # During the dual-write cycle the new school tables may not be fully
        # backfilled. If any submitted UUID is missing we skip the whole
        # Course::School sync so a partial resolution cannot remove existing
        # new-model rows.
        Rails.logger.warn(
          "[CourseSchools] skipped course_school sync - #{message}",
        )

        false
      end

      def missing_provider_school_uuids
        @missing_provider_school_uuids ||= submitted_school_uuids - provider_school_ids_by_uuid.keys
      end

      def raise_on_missing_provider_schools?
        @raise_on_missing_provider_schools
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
    end
  end
end
