class FixCourseApplicationOpenFromDates < ActiveRecord::Migration[6.0]
  def up
    recruitment_cycle = RecruitmentCycle.find_by(year: "2021")
    return if recruitment_cycle.nil?

    valid_start_date_range = recruitment_cycle.application_start_date..recruitment_cycle.application_end_date

    courses_with_invalid_start_date = recruitment_cycle.courses.where.not(applications_open_from: valid_start_date_range)

    courses_with_invalid_start_date.update_all(applications_open_from: recruitment_cycle.application_start_date)
  end

  def down
    # cannot go back as this will be invalid
  end
end
