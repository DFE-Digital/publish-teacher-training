# frozen_string_literal: true

class UniqueCourseSubject < ActiveRecord::Migration[6.0]
  def up
    Rails.logger.info { "De-duping course_subject. Count before: #{CourseSubject.count}" }
    # https://stackoverflow.com/questions/14124212/remove-duplicate-records-based-on-multiple-columns/14124391#14124391
    grouped = CourseSubject.all.group_by { |cs| [cs.course_id, cs.subject_id] }
    grouped.each_value do |dupes|
      dupes.shift
      dupes.each(&:destroy)
    end
    Rails.logger.info { "De-duping course_subject. Count after: #{CourseSubject.count}" }
    add_index :course_subject, %i[course_id subject_id], unique: true
  end

  def down
    remove_index :course_subject, %i[course_id subject_id]
  end
end
