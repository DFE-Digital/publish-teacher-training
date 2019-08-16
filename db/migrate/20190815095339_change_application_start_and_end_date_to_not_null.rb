class ChangeApplicationStartAndEndDateToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :recruitment_cycle, :application_start_date, false
    change_column_null :recruitment_cycle, :application_end_date, false
  end
end
