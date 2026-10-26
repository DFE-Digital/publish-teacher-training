# frozen_string_literal: true

class FeatureFlagState < ApplicationRecord
  # Dropped in this release. Keep ignoring it until that migration has run
  # in every environment, then remove this line.
  self.ignored_columns += %w[legacy_redis_synced_at]

  validates :name, presence: true
end
