class RemoveUCASSubjectAndCourseUCASSubject < ActiveRecord::Migration[6.0]
  def up
    drop_table :course_ucas_subject
    drop_table :ucas_subject
  end

  def down
    create_table "course_ucas_subject", id: :serial, force: :cascade do |t|
      t.integer "course_id"
      t.integer "ucas_subject_id"
      t.index %w[course_id], name: "IX_course_subject_course_id"
      t.index %w[ucas_subject_id], name: "IX_course_subject_subject_id"
    end

    create_table "ucas_subject", id: :serial, force: :cascade do |t|
      t.text "subject_name"
      t.text "subject_code", null: false
      t.index %w[subject_code], name: "AK_subject_subject_code", unique: true
      t.index %w[subject_name], name: "index_ucas_subject_on_subject_name"
    end
  end
end
