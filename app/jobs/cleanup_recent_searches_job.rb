# frozen_string_literal: true

class CleanupRecentSearchesJob < ApplicationJob
  def perform
    # Permanently delete discarded searches older than 1 day
    RecentSearch.discarded.where(discarded_at: ..1.day.ago).destroy_all

    # Permanently delete all searches (active or discarded) not updated in 30 days
    RecentSearch.where(updated_at: ..30.days.ago).destroy_all
  end
end
