# frozen_string_literal: true

class UpdateApplicationsOpenFrom < ActiveRecord::Migration[8.0]
  def up
    Course.where(applications_open_from: Date.new(2025, 9, 30))
      .update_all(applications_open_from: Find::CycleTimetable.apply_opens)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
