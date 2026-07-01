# frozen_string_literal: true

class AddPrimaryKeyToSubjectArea < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE subject_area
        ADD CONSTRAINT subject_area_pkey
        PRIMARY KEY USING INDEX index_subject_area_on_typename
      SQL
    end
  end

  def down
    remove_foreign_key :subject, name: "fk_subject__subject_area", if_exists: true

    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE subject_area
        DROP CONSTRAINT subject_area_pkey
      SQL
    end

    add_index :subject_area, :typename, unique: true, name: "index_subject_area_on_typename"
    add_subject_area_foreign_key
  end

private

  def add_subject_area_foreign_key
    safety_assured do
      add_foreign_key :subject,
                      :subject_area,
                      column: :type,
                      primary_key: :typename,
                      name: "fk_subject__subject_area"
    end
  end
end
