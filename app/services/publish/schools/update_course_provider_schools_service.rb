# frozen_string_literal: true

module Publish
  module Schools
    class UpdateCourseProviderSchoolsService
      include ServicePattern

      def initialize(course:, params:)
        @course = course
        @params = { school_uuids: current_school_uuids }.merge(params.to_h.deep_symbolize_keys)
      end

      def call
        return if provider_school_ids_to_attach.empty? && provider_school_ids_to_remove.empty?

        ActiveRecord::Base.transaction do
          provider_schools_to_attach.each { |provider_school| attach_provider_school(provider_school) }
          course.schools.where(provider_school_id: provider_school_ids_to_remove).destroy_all
          course.schools.reload
        end
      end

    private

      attr_reader :course, :params

      def attach_provider_school(provider_school)
        course.schools.find_or_create_by!(provider_school:) do |course_school|
          course_school.gias_school = provider_school.gias_school
        end
      rescue ActiveRecord::RecordNotUnique
        course.schools.find_by!(provider_school:)
      end

      def submitted_school_uuids
        @submitted_school_uuids ||= Array(params[:school_uuids]).compact_blank.map(&:to_s)
      end

      def current_school_uuids
        course.sites.map { |site| site.uuid.to_s }
      end

      def submitted_provider_schools
        @submitted_provider_schools ||= ProviderSchoolResolver.call(
          provider: course.provider,
          school_uuids: submitted_school_uuids,
        )
      end

      def submitted_provider_school_ids
        @submitted_provider_school_ids ||= submitted_provider_schools.map(&:id)
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
        @provider_schools_to_attach ||= submitted_provider_schools.select do |provider_school|
          provider_school.id.in?(provider_school_ids_to_attach)
        end
      end
    end
  end
end
