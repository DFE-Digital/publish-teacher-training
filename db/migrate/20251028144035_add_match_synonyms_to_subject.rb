class AddMatchSynonymsToSubject < ActiveRecord::Migration[8.0]
  def change
    add_column :subject, :match_synonyms, :jsonb, default: []
    add_index :subject, :match_synonyms, using: :gin
  end
end
