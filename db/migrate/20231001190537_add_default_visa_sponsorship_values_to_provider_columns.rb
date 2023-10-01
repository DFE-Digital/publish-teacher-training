# frozen_string_literal: true

class AddDefaultVisaSponsorshipValuesToProviderColumns < ActiveRecord::Migration[7.0]
  def change
    change_table :provider, bulk: true do |t|
      t.change_default :can_sponsor_skilled_worker_visa, from: nil, to: false
      t.change_default :can_sponsor_student_visa, from: nil, to: false
    end
  end
end
