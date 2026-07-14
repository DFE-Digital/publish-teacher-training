# frozen_string_literal: true

module Publish
  module Schools
    class ProviderSchoolResolver
      include ServicePattern

      def initialize(provider:, school_uuids:, gias_school_scope: GiasSchool.all)
        @provider = provider
        @school_uuids = Array(school_uuids).compact_blank.map(&:to_s)
        @gias_school_scope = gias_school_scope
      end

      def call
        school_uuids.filter_map { |uuid| provider_school_for(uuid) }.uniq(&:id)
      end

    private

      attr_reader :provider, :school_uuids, :gias_school_scope

      # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
      def provider_school_for(uuid)
        provider_schools_by_uuid[uuid] || provider_school_from_legacy_site(uuid)
      end

      def provider_schools_by_uuid
        @provider_schools_by_uuid ||= provider.schools.where(uuid: school_uuids).index_by { |school| school.uuid.to_s }
      end

      # TODO School data remodel removal - remove when submitted school UUIDs always refer to Provider::School rows.
      def provider_school_from_legacy_site(uuid)
        site = sites_by_uuid[uuid]
        return if site.blank?

        gias_school = gias_schools_by_urn[site.urn]
        return if gias_school.blank?

        provider_schools_by_gias_and_code[[gias_school.id, site.code]].tap do |provider_school|
          next if provider_school.present?

          Rails.logger.warn(
            "[CourseSchools] skipped course_school write — no provider_school for " \
            "provider=#{provider.id} site=#{site.id} site_uuid=#{site.uuid} gias_school=#{gias_school.id}",
          )
        end
      end

      # TODO School data remodel removal - remove with provider_school_from_legacy_site.
      def sites_by_uuid
        @sites_by_uuid ||= provider.sites.where(uuid: school_uuids).index_by { |site| site.uuid.to_s }
      end

      # TODO School data remodel removal - remove with provider_school_from_legacy_site.
      def gias_schools_by_urn
        @gias_schools_by_urn ||= gias_school_scope
          .where(urn: sites_by_uuid.values.map(&:urn).compact_blank)
          .index_by(&:urn)
      end

      # TODO School data remodel removal - remove with provider_school_from_legacy_site.
      def provider_schools_by_gias_and_code
        @provider_schools_by_gias_and_code ||= provider.schools
          .where(gias_school_id: gias_schools_by_urn.values.map(&:id))
          .index_by { |provider_school| [provider_school.gias_school_id, provider_school.site_code] }
      end
      # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
    end
  end
end
