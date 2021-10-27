class AllocationUplift < ApplicationRecord
  belongs_to :allocation

  extend Forwardable

  attr_accessor :allocation

  def_delegators :@allocation, :provider, :recruitment_cycle
end
