# frozen_string_literal: true

class ChangeApplicationStartAndEndDateToNotNull < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable Rails/BulkChangeTable
    change_column_null :recruitment_cycle, :application_start_date, false
    change_column_null :recruitment_cycle, :application_end_date, false
    # rubocop:enable Rails/BulkChangeTable
  end
end
