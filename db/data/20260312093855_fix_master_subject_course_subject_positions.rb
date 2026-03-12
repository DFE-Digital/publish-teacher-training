# frozen_string_literal: true

class FixMasterSubjectCourseSubjectPositions < ActiveRecord::Migration[8.1]
  def up
    Course.where.not(master_subject_id: nil).find_each do |course|
      Courses::ReorderCourseSubjectsService.call(course:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
