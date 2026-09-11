class CreateCourseSchoolBulkUpdateDraft < ActiveRecord::Migration[8.1]
  def change
    create_table :course_school_bulk_update_draft do |t|
      t.references :course, null: false, foreign_key: { to_table: :course, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { to_table: :user, on_delete: :cascade }
      t.uuid :uuid, null: false, default: -> { "uuid_generate_v4()" }
      t.uuid :school_uuids, array: true, null: false, default: []
      t.uuid :baseline_uuids, array: true, null: false, default: []
      t.string :scope
      t.datetime :expires_at, null: false

      t.timestamps
    end

    # The URL carries the uuid and the controller knows the course, so a draft
    # is always looked up by the pair. expires_at alone is for the sweep.
    add_index :course_school_bulk_update_draft, %i[course_id uuid], unique: true
    add_index :course_school_bulk_update_draft, :expires_at
  end
end
