# frozen_string_literal: true

class UpdateEtpField < ActiveRecord::Migration[7.0]
  def change
    change_table :course, bulk: true do |t|
      t.remove :campaign_name, type: :string
      t.column :campaign_name, :integer
      t.index :campaign_name
    end
  end
end
