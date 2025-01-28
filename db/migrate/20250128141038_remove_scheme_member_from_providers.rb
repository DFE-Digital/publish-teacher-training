# frozen_string_literal: true

class RemoveSchemeMemberFromProviders < ActiveRecord::Migration[8.0]
  def change
    remove_column :provider, :scheme_member, :text
  end
end
