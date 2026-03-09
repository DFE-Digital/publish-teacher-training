# frozen_string_literal: true

class FixModernLanguageCourseSubjectPositions < ActiveRecord::Migration[8.1]
  def up
    modern_languages_id = SecondarySubject.find_by(subject_name: "Modern Languages").id

    Course.where(master_subject_id: modern_languages_id).find_each do |course|
      Courses::ReorderModernLanguageSubjectsService.call(course:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
