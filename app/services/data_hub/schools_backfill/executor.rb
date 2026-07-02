# frozen_string_literal: true

module DataHub
  module SchoolsBackfill
    class Executor
      attr_reader :recruitment_cycle_years, :recruitment_cycle_ids

      def initialize(recruitment_cycle_years: nil)
        @recruitment_cycle_years = parse_recruitment_cycle_years(recruitment_cycle_years)
        @recruitment_cycle_ids = resolve_recruitment_cycle_ids
      end

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

      def parse_recruitment_cycle_years(raw_years)
        Array(raw_years)
          .flat_map { |value| value.to_s.split(",") }
          .map(&:strip)
          .reject(&:blank?)
          .uniq
      end

      def resolve_recruitment_cycle_ids
        return [] if recruitment_cycle_years.empty?

        ids_by_year = RecruitmentCycle.where(year: recruitment_cycle_years).pluck(:year, :id).to_h
        missing_years = recruitment_cycle_years - ids_by_year.keys

        if missing_years.any?
          raise ArgumentError, "Could not find recruitment cycle(s) for year(s): #{missing_years.join(', ')}"
        end

        ids_by_year.values
      end

      def scoped_to_recruitment_cycles?
        recruitment_cycle_ids.any?
      end

      def recruitment_cycle_ids_sql
        recruitment_cycle_ids.join(", ")
      end

      def site_provider_scope_join_sql
        return "" unless scoped_to_recruitment_cycles?

        "JOIN provider ON provider.id = site.provider_id"
      end

      def course_provider_scope_join_sql
        return "" unless scoped_to_recruitment_cycles?

        <<~SQL.squish
          JOIN course ON course.id = course_site.course_id
          JOIN provider ON provider.id = course.provider_id
        SQL
      end

      def recruitment_cycle_scope_sql
        return "" unless scoped_to_recruitment_cycles?

        "AND provider.recruitment_cycle_id IN (#{recruitment_cycle_ids_sql})"
      end

      def insert_provider_schools
        inserted_rows = ActiveRecord::Base.connection.exec_query(provider_schools_insert_sql)
        inserted_rows.length
      end

      def insert_course_schools
        inserted_rows = ActiveRecord::Base.connection.exec_query(course_schools_insert_sql)
        inserted_rows.length
      end

      # Builds the provider_school insert from readable CTEs. Main-site rows are
      # allowed to sit alongside non-main rows, while ordinary non-main rows are
      # deduplicated before the final idempotent INSERT.
      def provider_schools_insert_sql
        <<~SQL
          WITH #{main_site_provider_schools_cte},
               #{non_main_provider_schools_cte},
               #{source_provider_schools_cte}
          INSERT INTO provider_school (provider_id, gias_school_id, site_code, created_at, updated_at)
          SELECT provider_id, gias_school_id, site_code, NOW(), NOW()
          FROM source_provider_schools
          ON CONFLICT DO NOTHING
          RETURNING 1
        SQL
      end

      # Selects one main-site relationship per provider. Main sites are marked by
      # site.code = '-', and if legacy data has more than one, the earliest source
      # site wins to match the one-main-site-per-provider constraint.
      def main_site_provider_schools_cte
        <<~SQL.squish
          main_site_provider_schools AS (
            SELECT DISTINCT ON (site.provider_id)
                   site.provider_id,
                   gias_school.id AS gias_school_id,
                   site.code AS site_code
            FROM site
            #{site_provider_scope_join_sql}
            JOIN gias_school ON gias_school.urn = site.urn
            WHERE site.site_type = 0
              AND site.discarded_at IS NULL
              AND site.urn IS NOT NULL
              AND site.urn <> ''
              AND site.code = '-'
              #{recruitment_cycle_scope_sql}
            ORDER BY site.provider_id, site.id
          )
        SQL
      end

      # Selects ordinary provider-school relationships. The new model permits
      # only one non-main row for a provider/GIAS pair, so duplicate legacy rows
      # collapse to the earliest source site.
      def non_main_provider_schools_cte
        <<~SQL.squish
          non_main_provider_schools AS (
            SELECT DISTINCT ON (site.provider_id, gias_school.id)
                   site.provider_id,
                   gias_school.id AS gias_school_id,
                   site.code AS site_code
            FROM site
            #{site_provider_scope_join_sql}
            JOIN gias_school ON gias_school.urn = site.urn
            WHERE site.site_type = 0
              AND site.discarded_at IS NULL
              AND site.urn IS NOT NULL
              AND site.urn <> ''
              AND site.code <> '-'
              #{recruitment_cycle_scope_sql}
            ORDER BY site.provider_id, gias_school.id, site.id
          )
        SQL
      end

      # Combines the allowed main-site rows and deduplicated non-main rows into
      # the source relation used by the provider_school INSERT.
      def source_provider_schools_cte
        <<~SQL.squish
          source_provider_schools AS (
            SELECT * FROM main_site_provider_schools
            UNION ALL
            SELECT * FROM non_main_provider_schools
          )
        SQL
      end

      # Builds the course_school insert from readable CTEs. Course main-site rows
      # are allowed to sit alongside normal course-school rows for the same GIAS
      # school; ordinary non-main duplicates are collapsed before insert.
      def course_schools_insert_sql
        <<~SQL
          WITH #{main_site_course_schools_cte},
               #{non_main_course_schools_cte},
               #{source_course_schools_cte}
          INSERT INTO course_school (course_id, gias_school_id, site_code, created_at, updated_at)
          SELECT course_id, gias_school_id, site_code, NOW(), NOW()
          FROM source_course_schools
          ON CONFLICT DO NOTHING
          RETURNING 1
        SQL
      end

      # Selects course-level main-site relationships. site.code = '-' is the
      # marker that lets a main-site course_school row coexist with a normal row
      # for the same course/GIAS school.
      def main_site_course_schools_cte
        <<~SQL.squish
          main_site_course_schools AS (
            SELECT DISTINCT ON (course_site.course_id, gias_school.id)
                   course_site.course_id,
                   gias_school.id AS gias_school_id,
                   site.code AS site_code
            FROM course_site
            #{course_provider_scope_join_sql}
            JOIN site        ON site.id = course_site.site_id
            JOIN gias_school ON gias_school.urn = site.urn
            WHERE site.site_type = 0
              AND site.discarded_at IS NULL
              AND site.urn IS NOT NULL
              AND site.urn <> ''
              AND site.code = '-'
              #{recruitment_cycle_scope_sql}
            ORDER BY course_site.course_id, gias_school.id, site.id
          )
        SQL
      end

      # Selects ordinary course-school relationships. The new model permits only
      # one non-main row for a course/GIAS pair, so duplicate legacy course_site
      # rows collapse to the earliest source site.
      def non_main_course_schools_cte
        <<~SQL.squish
          non_main_course_schools AS (
            SELECT DISTINCT ON (course_site.course_id, gias_school.id)
                   course_site.course_id,
                   gias_school.id AS gias_school_id,
                   site.code AS site_code
            FROM course_site
            #{course_provider_scope_join_sql}
            JOIN site        ON site.id = course_site.site_id
            JOIN gias_school ON gias_school.urn = site.urn
            WHERE site.site_type = 0
              AND site.discarded_at IS NULL
              AND site.urn IS NOT NULL
              AND site.urn <> ''
              AND site.code <> '-'
              #{recruitment_cycle_scope_sql}
            ORDER BY course_site.course_id, gias_school.id, site.id
          )
        SQL
      end

      # Combines the allowed main-site rows and deduplicated non-main rows into
      # the source relation used by the course_school INSERT.
      def source_course_schools_cte
        <<~SQL.squish
          source_course_schools AS (
            SELECT * FROM main_site_course_schools
            UNION ALL
            SELECT * FROM non_main_course_schools
          )
        SQL
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
          #{site_provider_scope_join_sql}
          LEFT JOIN gias_school ON gias_school.urn = site.urn
          WHERE site.site_type = 0
            AND site.discarded_at IS NULL
            AND (site.urn IS NULL OR site.urn = '' OR gias_school.id IS NULL)
            #{recruitment_cycle_scope_sql}
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
                   ELSE 'urn_not_in_gias_school'
                 END AS reason
          FROM course_site
          #{course_provider_scope_join_sql}
          LEFT JOIN site        ON site.id = course_site.site_id
          LEFT JOIN gias_school ON gias_school.urn = site.urn
          WHERE (
              site.id IS NULL
              OR site.site_type <> 0
              OR site.discarded_at IS NOT NULL
              OR site.urn IS NULL
              OR site.urn = ''
              OR gias_school.id IS NULL
            )
            #{recruitment_cycle_scope_sql}
          ORDER BY course_site.course_id, course_site.site_id
        SQL
      end
    end
  end
end
