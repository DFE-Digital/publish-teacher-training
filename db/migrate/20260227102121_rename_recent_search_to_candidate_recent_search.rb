# frozen_string_literal: true

class RenameRecentSearchToCandidateRecentSearch < ActiveRecord::Migration[8.0]
  def change
    rename_table :recent_search, :candidate_recent_search

    # rename_table auto-renames indexes matching index_<table>_on_<column> pattern,
    # so only the custom-named indexes need explicit renaming
    rename_index :candidate_recent_search,
                 "index_recent_search_active_dedup",
                 "index_candidate_recent_search_active_dedup"

    rename_index :candidate_recent_search,
                 "index_recent_search_candidate_active_updated",
                 "index_candidate_recent_search_candidate_active_updated"
  end
end
