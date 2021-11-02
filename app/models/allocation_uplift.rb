class AllocationUplift < ApplicationRecord
  belongs_to :allocation

  delegate :provider, :recruitment_cycle, to: :allocation

  validates :uplifts, numericality: true
end
