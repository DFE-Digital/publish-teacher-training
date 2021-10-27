class AllocationUplift < ApplicationRecord
  extend Forwardable

  belongs_to :allocation
  def_delegators :@allocation, :provider, :accredited_body, :recruitment_cycle
end
