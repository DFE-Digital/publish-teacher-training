# frozen_string_literal: true

class RemoveTitleFromBanner < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :banner, :title, :string
      remove_column :banner, :title_heading_level, :integer
    end
  end
end
