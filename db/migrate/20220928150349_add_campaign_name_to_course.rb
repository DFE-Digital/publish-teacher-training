class AddCampaignNameToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :course, :campaign_name, :string, default: "no_campaign"
  end
end
