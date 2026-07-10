# frozen_string_literal: true

class SetCourseSchoolProviderSchoolIdNotNull < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # Add the constraint unvalidated first so we don't take a long
    # ACCESS EXCLUSIVE lock while every existing row is checked.
    add_check_constraint :course_school, "provider_school_id IS NOT NULL",
                         name: "course_school_provider_school_id_not_null", validate: false
    validate_check_constraint :course_school, name: "course_school_provider_school_id_not_null"

    change_column_null :course_school, :provider_school_id, false

    remove_check_constraint :course_school, name: "course_school_provider_school_id_not_null"
  end

  def down
    change_column_null :course_school, :provider_school_id, true
  end
end
