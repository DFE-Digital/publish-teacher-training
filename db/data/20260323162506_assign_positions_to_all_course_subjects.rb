# frozen_string_literal: true

class AssignPositionsToAllCourseSubjects < ActiveRecord::Migration[8.1]
  def up
    CourseSubject
      .where(position: nil)
      .select(:course_id)
      .distinct
      .pluck(:course_id)
      .each do |course_id|
        CourseSubject
          .where(course_id:, position: nil)
          .order(:id)
          .each_with_index do |cs, index|
            cs.update_column(:position, index)
          end
      end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
