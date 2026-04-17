# frozen_string_literal: true

require "csv"
require "fileutils"

module DataHub
  module SchoolsBackfill
    class Executor
      def initialize(tmp_dir: Rails.root.join("tmp"))
        @tmp_dir = Pathname.new(tmp_dir)
      end

      def execute
        process_summary = DataHub::SchoolsBackfillProcessSummary.start!

        skipped_sites_csv_path        = @tmp_dir.join("schools_backfill_skipped_sites_#{process_summary.id}.csv")
        skipped_course_sites_csv_path = @tmp_dir.join("schools_backfill_skipped_course_sites_#{process_summary.id}.csv")

        ActiveRecord::Base.transaction do
          sites_skipped             = write_skipped_sites_csv(skipped_sites_csv_path)
          provider_schools_inserted = insert_provider_schools

          course_sites_skipped    = write_skipped_course_sites_csv(skipped_course_sites_csv_path)
          course_schools_inserted = insert_course_schools

          process_summary.finish!(
            short_summary: {
              provider_schools_inserted: provider_schools_inserted,
              course_schools_inserted: course_schools_inserted,
              sites_skipped: sites_skipped,
              course_sites_skipped: course_sites_skipped,
            },
            full_summary: {
              skipped_sites_csv_path: skipped_sites_csv_path.to_s,
              skipped_course_sites_csv_path: skipped_course_sites_csv_path.to_s,
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
          INSERT INTO provider_school (provider_id, gias_school_id, site_code, created_at, updated_at)
          SELECT DISTINCT ON (site.provider_id, gias_school.id, site.code)
                 site.provider_id, gias_school.id, site.code, NOW(), NOW()
          FROM site
          JOIN gias_school ON gias_school.urn = site.urn
          WHERE site.site_type = 0
            AND site.discarded_at IS NULL
            AND site.urn IS NOT NULL
            AND site.urn <> ''
          ON CONFLICT DO NOTHING
          RETURNING 1
        SQL
        inserted_rows.length
      end

      def insert_course_schools
        inserted_rows = ActiveRecord::Base.connection.exec_query(<<~SQL)
          INSERT INTO course_school (course_id, gias_school_id, site_code, created_at, updated_at)
          SELECT DISTINCT ON (course_site.course_id, gias_school.id, site.code)
                 course_site.course_id, gias_school.id, site.code, NOW(), NOW()
          FROM course_site
          JOIN site        ON site.id = course_site.site_id
          JOIN gias_school ON gias_school.urn = site.urn
          WHERE site.site_type = 0
            AND site.discarded_at IS NULL
            AND site.urn IS NOT NULL
            AND site.urn <> ''
          ON CONFLICT DO NOTHING
          RETURNING 1
        SQL
        inserted_rows.length
      end

      def write_skipped_sites_csv(csv_path)
        skipped_rows = ActiveRecord::Base.connection.exec_query(<<~SQL).to_a
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
          LEFT JOIN gias_school ON gias_school.urn = site.urn
          WHERE site.site_type = 0
            AND site.discarded_at IS NULL
            AND (site.urn IS NULL OR site.urn = '' OR gias_school.id IS NULL)
          ORDER BY site.id
        SQL
        write_csv(csv_path, %w[site_id provider_id code urn location_name reason], skipped_rows)
        skipped_rows.length
      end

      def write_skipped_course_sites_csv(csv_path)
        skipped_rows = ActiveRecord::Base.connection.exec_query(<<~SQL).to_a
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
          LEFT JOIN site        ON site.id = course_site.site_id
          LEFT JOIN gias_school ON gias_school.urn = site.urn
          WHERE site.id IS NULL
             OR site.site_type <> 0
             OR site.discarded_at IS NOT NULL
             OR site.urn IS NULL
             OR site.urn = ''
             OR gias_school.id IS NULL
          ORDER BY course_site.course_id, course_site.site_id
        SQL
        write_csv(csv_path, %w[course_id site_id provider_id code urn reason], skipped_rows)
        skipped_rows.length
      end

      def write_csv(csv_path, headers, rows)
        FileUtils.mkdir_p(File.dirname(csv_path))
        CSV.open(csv_path, "w") do |csv|
          csv << headers
          rows.each { |row| csv << headers.map { |header| row[header] } }
        end
      end
    end
  end
end
