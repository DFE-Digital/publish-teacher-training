# frozen_string_literal: true

class BackfillCourseStudentVisaSettings < ActiveRecord::Migration[7.0]
  def up
    heis_who_can_sponsor_student_visa = Provider.where(can_sponsor_student_visa: true, provider_type: :university, accrediting_provider: :accredited_body)

    Course.where(provider: heis_who_can_sponsor_student_visa).or(
      Course.where(
        accredited_body_code: heis_who_can_sponsor_student_visa.select(:provider_code),
      ),
    ).update_all(can_sponsor_student_visa: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
