class RemoveRedundantGiasSchoolIdIndexFromCourseSchool < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # index_course_school_fanout (added in 20260717120000) is (gias_school_id)
  # INCLUDE (course_id). It has the same key column as the plain
  # index_course_school_on_gias_school_id, so it serves every lookup that one
  # did — and backs the gias_school FK cascade — while additionally covering
  # index-only fan-out scans. Keeping both just doubles write/storage cost for
  # no planner benefit, so drop the plain one.
  def up
    remove_index :course_school, name: "index_course_school_on_gias_school_id", algorithm: :concurrently
  end

  def down
    add_index :course_school, :gias_school_id, name: "index_course_school_on_gias_school_id", algorithm: :concurrently
  end
end
