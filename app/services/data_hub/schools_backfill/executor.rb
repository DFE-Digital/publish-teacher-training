# frozen_string_literal: true

module DataHub
  module SchoolsBackfill
    class Executor
      # Only backfill the 2026 recruitment cycle onwards; earlier cycles are
      # historic and are not being remodelled.
      FROM_RECRUITMENT_CYCLE_YEAR = 2026

      def execute
        process_summary = DataHub::SchoolsBackfillProcessSummary.start!

        ActiveRecord::Base.transaction do
          skipped_sites             = fetch_skipped_sites
          provider_schools_inserted = insert_provider_schools

          skipped_course_sites    = fetch_skipped_course_sites
          course_schools_inserted = insert_course_schools

          process_summary.finish!(
            short_summary: {
              provider_schools_inserted: provider_schools_inserted,
              course_schools_inserted: course_schools_inserted,
              sites_skipped: skipped_sites.length,
              course_sites_skipped: skipped_course_sites.length,
            },
            full_summary: {
              skipped_sites: skipped_sites,
              skipped_course_sites: skipped_course_sites,
            },
          )
        end

        process_summary
      rescue StandardError => e
        process_summary&.fail!(e)
        raise
      end

    private

      def insert_provider_schools
        inserted_rows = ActiveRecord::Base.connection.exec_query(<<~SQL)
          INSERT INTO provider_school (provider_id, gias_school_id, site_code, uuid, created_at, updated_at)
          SELECT DISTINCT ON (site.provider_id, gias_school.id, site.code)
                 site.provider_id, gias_school.id, site.code, site.uuid, NOW(), NOW()
          FROM site
          JOIN gias_school       ON gias_school.urn = site.urn
          JOIN provider          ON provider.id = site.provider_id
          JOIN recruitment_cycle ON recruitment_cycle.id = provider.recruitment_cycle_id
          WHERE recruitment_cycle.year::int >= #{FROM_RECRUITMENT_CYCLE_YEAR}
            AND site.site_type = 0
            AND site.discarded_at IS NULL
            AND site.urn IS NOT NULL
            AND site.urn <> ''
          ON CONFLICT (provider_id, gias_school_id, site_code) DO UPDATE
            SET uuid = EXCLUDED.uuid,
                updated_at = NOW()
            WHERE provider_school.uuid IS DISTINCT FROM EXCLUDED.uuid
          RETURNING 1
        SQL
        inserted_rows.length
      end

      def insert_course_schools
        return insert_course_schools_with_site_code if course_school_has_site_code?

        inserted_rows = ActiveRecord::Base.connection.exec_query(<<~SQL)
          INSERT INTO course_school (course_id, gias_school_id, provider_school_id, created_at, updated_at)
          SELECT DISTINCT ON (course_site.course_id, provider_school.id)
                 course_site.course_id, gias_school.id, provider_school.id, NOW(), NOW()
          FROM course_site
          JOIN site              ON site.id = course_site.site_id
          JOIN gias_school       ON gias_school.urn = site.urn
          JOIN provider          ON provider.id = site.provider_id
          JOIN recruitment_cycle ON recruitment_cycle.id = provider.recruitment_cycle_id
          JOIN provider_school   ON provider_school.provider_id = site.provider_id
                                AND provider_school.gias_school_id = gias_school.id
                                AND provider_school.site_code = site.code
          WHERE recruitment_cycle.year::int >= #{FROM_RECRUITMENT_CYCLE_YEAR}
            AND site.site_type = 0
            AND site.discarded_at IS NULL
            AND site.urn IS NOT NULL
            AND site.urn <> ''
          ON CONFLICT DO NOTHING
          RETURNING 1
        SQL
        inserted_rows.length
      end

      def insert_course_schools_with_site_code
        inserted_rows = ActiveRecord::Base.connection.exec_query(<<~SQL)
          INSERT INTO course_school (course_id, gias_school_id, provider_school_id, site_code, created_at, updated_at)
          SELECT DISTINCT ON (course_site.course_id, provider_school.id)
                 course_site.course_id, gias_school.id, provider_school.id, provider_school.site_code, NOW(), NOW()
          FROM course_site
          JOIN site              ON site.id = course_site.site_id
          JOIN gias_school       ON gias_school.urn = site.urn
          JOIN provider          ON provider.id = site.provider_id
          JOIN recruitment_cycle ON recruitment_cycle.id = provider.recruitment_cycle_id
          JOIN provider_school   ON provider_school.provider_id = site.provider_id
                                AND provider_school.gias_school_id = gias_school.id
                                AND provider_school.site_code = site.code
          WHERE recruitment_cycle.year::int >= #{FROM_RECRUITMENT_CYCLE_YEAR}
            AND site.site_type = 0
            AND site.discarded_at IS NULL
            AND site.urn IS NOT NULL
            AND site.urn <> ''
          ON CONFLICT DO NOTHING
          RETURNING 1
        SQL
        inserted_rows.length
      end

      def course_school_has_site_code?
        @course_school_has_site_code ||= Course::School.column_names.include?("site_code")
      end

      def fetch_skipped_sites
        ActiveRecord::Base.connection.exec_query(<<~SQL).to_a
          SELECT site.id AS site_id,
                 site.provider_id,
                 site.code,
                 site.urn,
                 site.location_name,
                 CASE
                   WHEN site.urn IS NULL OR site.urn = '' THEN 'no_urn'
                   ELSE 'urn_not_in_gias_school'
                 END AS reason
          FROM site
          JOIN provider          ON provider.id = site.provider_id
          JOIN recruitment_cycle ON recruitment_cycle.id = provider.recruitment_cycle_id
          LEFT JOIN gias_school  ON gias_school.urn = site.urn
          WHERE recruitment_cycle.year::int >= #{FROM_RECRUITMENT_CYCLE_YEAR}
            AND site.site_type = 0
            AND site.discarded_at IS NULL
            AND (site.urn IS NULL OR site.urn = '' OR gias_school.id IS NULL)
          ORDER BY site.id
        SQL
      end

      def fetch_skipped_course_sites
        ActiveRecord::Base.connection.exec_query(<<~SQL).to_a
          SELECT course_site.course_id,
                 course_site.site_id,
                 site.provider_id,
                 site.code,
                 site.urn,
                 CASE
                   WHEN site.id IS NULL THEN 'site_missing'
                   WHEN site.site_type <> 0 THEN 'non_school_site'
                   WHEN site.discarded_at IS NOT NULL THEN 'site_discarded'
                   WHEN site.urn IS NULL OR site.urn = '' THEN 'no_urn'
                   WHEN gias_school.id IS NULL THEN 'urn_not_in_gias_school'
                   WHEN provider_school.id IS NULL THEN 'provider_school_missing'
                   ELSE 'urn_not_in_gias_school'
                 END AS reason
          FROM course_site
          JOIN course               ON course.id = course_site.course_id
          JOIN provider             ON provider.id = course.provider_id
          JOIN recruitment_cycle    ON recruitment_cycle.id = provider.recruitment_cycle_id
          LEFT JOIN site            ON site.id = course_site.site_id
          LEFT JOIN gias_school     ON gias_school.urn = site.urn
          LEFT JOIN provider_school ON provider_school.provider_id = site.provider_id
                                  AND provider_school.gias_school_id = gias_school.id
                                  AND provider_school.site_code = site.code
          WHERE recruitment_cycle.year::int >= #{FROM_RECRUITMENT_CYCLE_YEAR}
            AND (site.id IS NULL
             OR site.site_type <> 0
             OR site.discarded_at IS NOT NULL
             OR site.urn IS NULL
             OR site.urn = ''
             OR gias_school.id IS NULL
             OR provider_school.id IS NULL)
          ORDER BY course_site.course_id, course_site.site_id
        SQL
      end
    end
  end
end
