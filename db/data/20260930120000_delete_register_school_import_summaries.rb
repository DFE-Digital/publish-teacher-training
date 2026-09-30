# frozen_string_literal: true

class DeleteRegisterSchoolImportSummaries < ActiveRecord::Migration[8.1]
  # DataHub::RegisterSchoolImportSummary is removed, so rows of that STI type
  # raise ActiveRecord::SubclassNotFound when loaded. delete_all runs as SQL
  # and does not load them.
  def up
    DataHub::ProcessSummary
      .where(type: "DataHub::RegisterSchoolImportSummary")
      .delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
