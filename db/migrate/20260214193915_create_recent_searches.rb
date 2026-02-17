# frozen_string_literal: true

class CreateRecentSearches < ActiveRecord::Migration[8.0]
  def change
    create_table :recent_search do |t|
      t.references :candidate, null: false, foreign_key: true
      t.string     :subjects, array: true, default: []
      t.float      :longitude
      t.float      :latitude
      t.integer    :radius
      t.jsonb      :search_attributes, default: {}
      t.datetime   :discarded_at

      t.timestamps
    end

    add_index :recent_search,
              %i[candidate_id subjects longitude latitude radius],
              unique: true,
              where: "discarded_at IS NULL",
              name: "index_recent_search_active_dedup"

    add_index :recent_search,
              %i[candidate_id discarded_at updated_at],
              name: "index_recent_search_candidate_active_updated"

    add_index :recent_search, :discarded_at
  end
end
