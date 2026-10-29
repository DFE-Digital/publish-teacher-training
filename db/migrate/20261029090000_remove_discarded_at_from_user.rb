# frozen_string_literal: true

class RemoveDiscardedAtFromUser < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :user, :discarded_at, :datetime, precision: nil
    end
  end
end
