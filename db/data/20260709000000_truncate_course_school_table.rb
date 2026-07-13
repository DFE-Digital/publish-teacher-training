# frozen_string_literal: true

class TruncateCourseSchoolTable < ActiveRecord::Migration[8.1]
  TAG = "[BackfillCourseSchoolProviderSchoolIds]"

  def up
    # This table is not in use in production yet so it's safe to truncate when setting the columns to not-null
    exec_delete("TRUNCATE TABLE course_school;")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
