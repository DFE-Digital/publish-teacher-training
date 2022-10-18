class UpdateEtpField < ActiveRecord::Migration[7.0]
  def change
    remove_column :course, :campaign_name, :string
    add_column :course, :campaign_name, :integer
    add_index :course, :campaign_name
  end
end
