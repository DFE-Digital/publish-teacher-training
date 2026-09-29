# frozen_string_literal: true

# rename_table does not rename foreign keys, so databases migrated through the
# email_alert and recent_search renames keep names derived from the old table
# names. Databases built from db/schema.rb get names derived from the new ones.
# This aligns the two so a sanitised production dump restores cleanly over a
# review app database created with db:setup.
class RenameCandidateForeignKeys < ActiveRecord::Migration[8.1]
  FOREIGN_KEYS = [
    { table: :candidate_email_alerts, from: "fk_rails_6b8e3f6df0", to: "fk_rails_3e6c092d1c" },
    { table: :candidate_recent_search, from: "fk_rails_23deb0ec7e", to: "fk_rails_edb976f372" },
  ].freeze

  def up
    FOREIGN_KEYS.each { |fk| rename_constraint(fk[:table], fk[:from], fk[:to]) }
  end

  def down
    FOREIGN_KEYS.each { |fk| rename_constraint(fk[:table], fk[:to], fk[:from]) }
  end

private

  def rename_constraint(table, from, to)
    return unless foreign_keys(table).any? { |fk| fk.name == from }

    # Renaming a constraint is a catalogue-only change: no table scan or rewrite.
    safety_assured do
      execute "ALTER TABLE #{quote_table_name(table)} RENAME CONSTRAINT #{quote_column_name(from)} TO #{quote_column_name(to)}"
    end
  end
end
