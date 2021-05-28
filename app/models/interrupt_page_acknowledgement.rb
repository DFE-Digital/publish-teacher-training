class InterruptPageAcknowledgement < ApplicationRecord
  belongs_to :user
  belongs_to :recruitment_cycle

  ALL_PAGES = %w[rollover rollover_recruitment].freeze

  enum page: ALL_PAGES.zip(ALL_PAGES).to_h
end
