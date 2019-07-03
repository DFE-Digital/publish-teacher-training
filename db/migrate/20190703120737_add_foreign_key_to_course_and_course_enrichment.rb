class AddForeignKeyToCourseAndCourseEnrichment < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :course_enrichment, :course
  end
end
