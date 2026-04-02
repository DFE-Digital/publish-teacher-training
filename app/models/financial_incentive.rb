# frozen_string_literal: true

class FinancialIncentive < ApplicationRecord
  belongs_to :subject

  scope :with_incentive, -> { where.not(bursary_amount: nil, scholarship: nil) }
end
