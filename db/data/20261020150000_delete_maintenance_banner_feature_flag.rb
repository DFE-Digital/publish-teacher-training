# frozen_string_literal: true

class DeleteMaintenanceBannerFeatureFlag < ActiveRecord::Migration[8.1]
  # The maintenance_banner flag is removed from FeatureFlags.all, so nothing
  # reads its row and nothing creates it again once deleted.
  def up
    FeatureFlagState.where(name: "maintenance_banner").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
