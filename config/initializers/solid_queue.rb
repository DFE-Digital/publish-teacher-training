# frozen_string_literal: true

# App-wide pluralize_table_names is false. Solid Queue's schema uses the gem default.
ActiveSupport.on_load(:solid_queue_record) do
  self.pluralize_table_names = true
end
