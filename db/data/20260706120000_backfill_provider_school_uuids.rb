# frozen_string_literal: true

class BackfillProviderSchoolUuids < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  TAG = "[BackfillProviderSchoolUuids]"

  def up
    total = 0

    Provider::School.unscoped.where(uuid: nil).in_batches(of: 5_000) do |batch|
      total += batch.update_all("uuid = uuid_generate_v4()")
    end

    say "#{TAG} backfilled=#{total}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
