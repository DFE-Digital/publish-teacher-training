# frozen_string_literal: true

# This migration adds columns to the provider table for the "Why Train With Us" section.
class AddWhyTrainWithUsColumnsToProvider < ActiveRecord::Migration[8.0]
  # This migration adds columns to the provider table for the "Why Train With Us" section.
  def change
    change_table(:provider) do |t|
      t.string :self_description
      t.string :provider_value_proposition
    end
  end
end
