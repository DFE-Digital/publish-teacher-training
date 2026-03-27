# frozen_string_literal: true

class FixSubjectCourseSubjectPositions < ActiveRecord::Migration[8.1]
  def up
    current_cycle = Course.with_recruitment_cycle(RecruitmentCycle.current.year)

    # Reorder primary and secondary courses (have master_subject_id)
    current_cycle.where.not(master_subject_id: nil).find_each do |course|
      Courses::ReorderCourseSubjectsService.call(course:)
    end

    # FE courses have a single subject — just set position to 0
    CourseSubject
      .where(course_id: current_cycle.where(master_subject_id: nil).select(:id), position: nil)
      .update_all(position: 0)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
