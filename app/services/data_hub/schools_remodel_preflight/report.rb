# frozen_string_literal: true

module DataHub
  module SchoolsRemodelPreflight
    # Read-only data checks that gate moving the course school pickers off
    # legacy Site records and onto Provider::School.
    #
    # The pickers key on uuid, relying on provider_school.uuid being a copy of
    # site.uuid — written that way by the dual-write in
    # Publish::Providers::Schools::ChecksController and by
    # DataHub::SchoolsBackfill::Executor. These checks find the rows where that
    # pairing has broken.
    #
    #   orphan_provider_schools — a Provider::School with no kept school Site.
    #     BLOCKING: Provider::School has no discarded_at, so a site removed by
    #     discard_invalid_schools / remove_provider_schools can leave its
    #     provider_school behind. Those schools would reappear in the migrated
    #     picker despite having been deliberately removed.
    #
    #   unmapped_sites — a kept school Site with no Provider::School. These
    #     schools would vanish from the picker. Not blocking, but each one is a
    #     school a provider can no longer attach.
    #
    #   unmapped_attachments — a live course_site row with no course_school
    #     row. These render unticked unless the picker unions them back in.
    class Report
      Result = Struct.new(
        :orphan_provider_schools,
        :unmapped_sites,
        :unmapped_attachments,
        keyword_init: true,
      ) do
        # Only orphaned provider_schools resurrect a removed school in the
        # picker, so only they stop the migration.
        def blocking? = orphan_provider_schools.any?

        def counts
          {
            orphan_provider_schools: orphan_provider_schools.length,
            unmapped_sites: unmapped_sites.length,
            unmapped_attachments: unmapped_attachments.length,
          }
        end
      end

      # Site#site_type: 0 is `school`, 1 is `study_site`. The new model covers
      # schools only — study sites have no Provider::School equivalent.
      SCHOOL_SITE_TYPE = 0

      # SiteStatus statuses the picker treats as attached, matching the
      # Course#sites association scope (new_status, running).
      ATTACHED_STATUSES = %w[N R].freeze

      def initialize(recruitment_cycle_year:)
        @recruitment_cycle_year = recruitment_cycle_year.to_s
      end

      def call
        Result.new(
          orphan_provider_schools: query(orphan_provider_schools_sql),
          unmapped_sites: query(unmapped_sites_sql),
          unmapped_attachments: query(unmapped_attachments_sql),
        )
      end

    private

      attr_reader :recruitment_cycle_year

      def query(sql)
        ActiveRecord::Base.connection.exec_query(
          ActiveRecord::Base.sanitize_sql_array(
            [sql, { year: recruitment_cycle_year, school: SCHOOL_SITE_TYPE, attached: ATTACHED_STATUSES }],
          ),
        ).to_a
      end

      def orphan_provider_schools_sql
        <<~SQL.squish
          SELECT provider_school.id   AS provider_school_id,
                 provider.provider_code,
                 provider_school.site_code,
                 gias_school.urn,
                 gias_school.name
          FROM provider_school
          JOIN provider          ON provider.id = provider_school.provider_id
          JOIN recruitment_cycle ON recruitment_cycle.id = provider.recruitment_cycle_id
          JOIN gias_school       ON gias_school.id = provider_school.gias_school_id
          LEFT JOIN site ON site.uuid = provider_school.uuid
                        AND site.discarded_at IS NULL
                        AND site.site_type = :school
          WHERE recruitment_cycle.year = :year
            AND site.id IS NULL
          ORDER BY provider.provider_code, provider_school.site_code
        SQL
      end

      def unmapped_sites_sql
        <<~SQL.squish
          SELECT site.id AS site_id,
                 provider.provider_code,
                 site.code,
                 site.urn,
                 site.location_name
          FROM site
          JOIN provider          ON provider.id = site.provider_id
          JOIN recruitment_cycle ON recruitment_cycle.id = provider.recruitment_cycle_id
          LEFT JOIN provider_school ON provider_school.uuid = site.uuid
          WHERE recruitment_cycle.year = :year
            AND site.site_type = :school
            AND site.discarded_at IS NULL
            AND provider_school.id IS NULL
          ORDER BY provider.provider_code, site.code
        SQL
      end

      def unmapped_attachments_sql
        <<~SQL.squish
          SELECT course_site.course_id,
                 course_site.site_id,
                 provider.provider_code,
                 course.course_code,
                 site.code,
                 site.urn
          FROM course_site
          JOIN course            ON course.id = course_site.course_id
          JOIN provider          ON provider.id = course.provider_id
          JOIN recruitment_cycle ON recruitment_cycle.id = provider.recruitment_cycle_id
          JOIN site              ON site.id = course_site.site_id
          LEFT JOIN provider_school ON provider_school.uuid = site.uuid
          LEFT JOIN course_school   ON course_school.course_id = course.id
                                   AND course_school.provider_school_id = provider_school.id
          WHERE recruitment_cycle.year = :year
            AND site.site_type = :school
            AND course_site.status IN (:attached)
            AND course_school.id IS NULL
          ORDER BY course_site.course_id, course_site.site_id
        SQL
      end
    end
  end
end
