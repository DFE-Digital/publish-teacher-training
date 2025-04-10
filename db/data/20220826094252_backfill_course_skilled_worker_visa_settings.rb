# frozen_string_literal: true

class BackfillCourseSkilledWorkerVisaSettings < ActiveRecord::Migration[7.0]
  def up
    Course.where(
      provider: Provider.where(can_sponsor_skilled_worker_visa: true),
    ).update_all(can_sponsor_skilled_worker_visa: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
