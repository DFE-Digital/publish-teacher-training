class AddCourseRefToCourseEnrichment < ActiveRecord::Migration[5.2]
  def up
    add_reference :course_enrichment, :course, index: true, type: :int

    execute <<-SQL
    UPDATE course_enrichment
    SET    course_id =
           (
                  SELECT course.id
                  FROM   course
                  join   provider
                  ON     course.provider_id                 = provider.id
                  AND    course_enrichment.provider_code    = provider.provider_code
                  AND    course_enrichment.ucas_course_code = course.course_code)
    SQL

    change_column_null :course_enrichment, :course_id, false
  end

  def down
    remove_reference :course_enrichment, :course
  end
end
