class RenamePrimaryKeyIndexSubject < ActiveRecord::Migration[5.2]
  def up
    execute 'ALTER INDEX IF EXISTS "PK_ucas_subject" RENAME TO "subject_pkey"'
    execute 'ALTER INDEX IF EXISTS "PK_course_subject" RENAME TO "course_subject_pkey"'
  end

  def down
    # It's covered in up, entity framework dotnet convention clash
  end
end
