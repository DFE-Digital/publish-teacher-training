# frozen_string_literal: true

class DeleteInterruptPageAcknowledgementTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :interrupt_page_acknowledgement do |t|
      t.string 'page', null: false
      t.bigint 'recruitment_cycle_id', null: false
      t.bigint 'user_id', null: false
      t.timestamps

      t.index %w[page recruitment_cycle_id user_id], name: 'interrupt_page_all_column_idx', unique: true
      t.index ['recruitment_cycle_id'], name: 'index_interrupt_page_acknowledgement_on_recruitment_cycle_id'
      t.index ['user_id'], name: 'index_interrupt_page_acknowledgement_on_user_id'
    end
  end
end
