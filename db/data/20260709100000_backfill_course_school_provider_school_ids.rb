# frozen_string_literal: true

class BackfillCourseSchoolProviderSchoolIds < ActiveRecord::Migration[8.1]
  TAG = "[BackfillCourseSchoolProviderSchoolIds]"

  def up
    # Link rows written before provider_school_id existed, using the same
    # lookup CourseSchools::Creator does (course's provider + gias_school).
    backfilled = exec_update(<<~SQL)
      UPDATE course_school
      SET provider_school_id = provider_school.id
      FROM course, provider_school
      WHERE course.id = course_school.course_id
        AND provider_school.provider_id = course.provider_id
        AND provider_school.gias_school_id = course_school.gias_school_id
        AND provider_school.site_code = course_school.site_code
        AND course_school.provider_school_id IS NULL
    SQL

    # Rows whose provider_school has since been deleted cannot be linked;
    # the ON DELETE CASCADE would have removed them had the column existed
    # from the start, and a rerun of the schools backfill recreates them if
    # the school is re-added.
    deleted = exec_delete("DELETE FROM course_school WHERE provider_school_id IS NULL")

    say "#{TAG} backfilled=#{backfilled} deleted=#{deleted}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
