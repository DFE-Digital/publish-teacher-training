# frozen_string_literal: true

class CreateGiasSchool < ActiveRecord::Migration[7.0]
  def change
    create_table :gias_school do |t|
      t.text 'urn', index: true, null: false
      t.text 'name', null: false
      t.text 'type_code'
      t.text 'group_code'
      t.text 'status_code'
      t.text 'phase_code'
      t.text 'minimum_age'
      t.text 'maximum_age'
      t.text 'ukprn'
      t.text 'address1', null: false
      t.text 'address2'
      t.text 'address3'
      t.text 'town', null: false
      t.text 'county'
      t.text 'postcode', null: false
      t.text 'website'
      t.text 'telephone'
      t.timestamps
    end
  end
end
