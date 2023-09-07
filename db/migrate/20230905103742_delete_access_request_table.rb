# frozen_string_literal: true

class DeleteAccessRequestTable < ActiveRecord::Migration[7.0]
  def change
    create_table 'access_request', id: :serial, force: :cascade do |t|
      t.text 'email_address'
      t.text 'first_name'
      t.text 'last_name'
      t.text 'organisation'
      t.text 'reason'
      t.datetime 'request_date_utc', precision: nil, null: false
      t.integer 'requester_id'
      t.integer 'status', null: false
      t.text 'requester_email'
      t.datetime 'discarded_at', precision: nil
      t.index ['discarded_at'], name: 'index_access_request_on_discarded_at'
      t.index ['requester_id'], name: 'IX_access_request_requester_id'
    end
  end
end
