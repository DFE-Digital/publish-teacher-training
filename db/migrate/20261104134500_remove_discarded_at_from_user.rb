# frozen_string_literal: true

class RemoveDiscardedAtFromUser < ActiveRecord::Migration[8.1]
  def change
    # Safe to remove: User already ignores discarded_at, introduced in:
    # https://github.com/DFE-Digital/publish-teacher-training/pull/6661
    safety_assured do
      remove_column :user, :discarded_at, :datetime, precision: nil
    end
  end
end
