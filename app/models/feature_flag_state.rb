# frozen_string_literal: true

class FeatureFlagState < ApplicationRecord
  # Keep the column for old pods during this rollout; drop it in a later release.
  self.ignored_columns += %w[legacy_redis_synced_at]

  validates :name, presence: true
end
