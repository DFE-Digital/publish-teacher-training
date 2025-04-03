Rails.application.config.after_initialize do
  Audited::Audit.table_name = "audit"
end
