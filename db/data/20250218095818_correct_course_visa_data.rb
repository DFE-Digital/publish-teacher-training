# frozen_string_literal: true

class CorrectCourseVisaData < ActiveRecord::Migration[8.0]
  def up
    Course.where(funding: "apprenticeship", can_sponsor_student_visa: true).update_all(can_sponsor_student_visa: false)
    Course.where(funding: "salary", can_sponsor_student_visa: true).update_all(can_sponsor_student_visa: false)
    Course.where(funding: "fee", can_sponsor_skilled_worker_visa: true).update_all(can_sponsor_skilled_worker_visa: false)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
