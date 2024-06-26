# frozen_string_literal: true

class AddAcceptPendingALevelToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :accept_pending_a_level, :boolean
  end
end
