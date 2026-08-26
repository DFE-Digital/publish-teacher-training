# frozen_string_literal: true

class RemoveHeadingFromBanner < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :banner, :heading, :string }
  end
end
