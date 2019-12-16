# rubocop:todo Rails/CreateTableWithTimestamps
class CreateCourseSubjectTable < ActiveRecord::Migration[5.2]
  def change
    create_table "course_subject", id: :serial, force: :cascade do |t|
      t.integer "course_id"
      t.integer "subject_id"
      t.index %w[course_id], name: "index_course_subject_on_course_id"
      t.index %w[subject_id], name: "index_course_subject_on_subject_id"
    end
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
