# frozen_string_literal: true

class ResetVisaSponsorshipDeadlineForRolledoverCourses < ActiveRecord::Migration[8.0]
  def up
    # Set to nil the visa_sponsorship_application_deadline_at for all courses in 2026 where the existing value is before find opens.
    Course.with_recruitment_cycle(2026)
      .where.not(visa_sponsorship_application_deadline_at: nil)
      .where("visa_sponsorship_application_deadline_at < ?", Find::CycleTimetable.find_opens(2026))
      .update_all(visa_sponsorship_application_deadline_at: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
