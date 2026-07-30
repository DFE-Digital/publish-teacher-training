# frozen_string_literal: true

module Publish
  module Schools
    # Syncs Course::School rows to an already-resolved Provider::School selection.
    # UUID resolution and queued-update policy belong to UpdateCourseSchoolsService.
    class UpdateCourseProviderSchoolsService
      include ServicePattern

      # @param course [Course] course whose Course::School rows should be synced
      # @param provider_schools [Array<Provider::School>] complete desired selection
      def initialize(course:, provider_schools:)
        @course = course
        @provider_schools = provider_schools
      end

      def call
        return if provider_school_ids_to_attach.empty? && provider_school_ids_to_remove.empty?

        provider_schools_to_attach.each { |provider_school| attach_provider_school(provider_school) }
        course.schools.where(provider_school_id: provider_school_ids_to_remove).destroy_all
        course.schools.reload
      end

    private

      attr_reader :course, :provider_schools

      def attach_provider_school(provider_school)
        course.schools.create_or_find_by!(provider_school:) do |course_school|
          course_school.gias_school = provider_school.gias_school
        end
      end

      def submitted_provider_school_ids
        @submitted_provider_school_ids ||= provider_schools.map(&:id)
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
        schools_by_id = provider_schools.index_by(&:id)
        provider_school_ids_to_attach.map { |id| schools_by_id.fetch(id) }
      end
    end
  end
end
