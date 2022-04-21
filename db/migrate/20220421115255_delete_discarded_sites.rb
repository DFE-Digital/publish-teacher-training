class DeleteDiscardedSites < ActiveRecord::Migration[6.1]
  def up
    SiteStatus.includes(:site).where.not(site: { discarded_at: nil }).destroy_all
    Site.where.not(discarded_at: nil).destroy_all
  end

  def down
    # There is no need to go back.
  end
end
