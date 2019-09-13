class ChangedSubjectIdToUCASSubjectId < ActiveRecord::Migration[5.2]
  def change
    rename_column :course_ucas_subject, :subject_id, :ucas_subject_id
  end
end
