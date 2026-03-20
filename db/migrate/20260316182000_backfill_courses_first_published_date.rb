class BackfillCoursesFirstPublishedDate < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      UPDATE course
      SET first_published_date = first_published_enrichment.first_created_at::date
      FROM (
        SELECT
          course_id,
          MIN(created_at) AS first_created_at
        FROM course_enrichment
        WHERE status = 1
        GROUP BY course_id
      ) AS first_published_enrichment
      WHERE course.id = first_published_enrichment.course_id
        AND course.first_published_date IS NULL
    SQL
  end

  def down; end
end
