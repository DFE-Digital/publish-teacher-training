class RenameAuditTableToAudits < ActiveRecord::Migration[8.0]
  def change
    rename_table :audit, :audits
  end
end
