# frozen_string_literal: true

class SetProviderSchoolUuidNotNull < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # Add the constraint unvalidated first so we don't take a long
    # ACCESS EXCLUSIVE lock while every existing row is checked.
    add_check_constraint :provider_school, "uuid IS NOT NULL",
                         name: "provider_school_uuid_not_null", validate: false
    validate_check_constraint :provider_school, name: "provider_school_uuid_not_null"

    change_column_null :provider_school, :uuid, false

    remove_check_constraint :provider_school, name: "provider_school_uuid_not_null"
  end

  def down
    change_column_null :provider_school, :uuid, true
  end
end
