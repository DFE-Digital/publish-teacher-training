# frozen_string_literal: true

namespace :courses do
  desc "Backfill courses.first_published_date from latest published enrichment created_at"
  task backfill_first_published_date: :environment do
    sql = <<~SQL.squish
      UPDATE course
      SET first_published_date = latest_published_enrichment.latest_created_at::date
      FROM (
        SELECT
          course_id,
          MAX(created_at) AS latest_created_at
        FROM course_enrichment
        WHERE status = 1
        GROUP BY course_id
      ) AS latest_published_enrichment
      WHERE course.id = latest_published_enrichment.course_id
        AND course.first_published_date IS NULL
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end
end
