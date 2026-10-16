# frozen_string_literal: true

class FeatureFlagState < ApplicationRecord
  validates :name, presence: true
end
