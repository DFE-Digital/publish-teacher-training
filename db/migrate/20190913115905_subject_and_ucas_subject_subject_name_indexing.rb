class SubjectAndUCASSubjectSubjectNameIndexing < ActiveRecord::Migration[5.2]
  def change
    say_with_time 'index subject name for subject and ucas subject' do
      add_index :subject, :subject_name
      add_index :ucas_subject, :subject_name
    end
  end
end
