# == Schema Information
#
# Table name: financial_incentive
#
#  id                    :bigint           not null, primary key
#  subject_id            :bigint           not null
#  bursary_amount        :string
#  early_career_payments :string
#  scholarship           :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class FinancialIncentive < ApplicationRecord
  belongs_to :subject
end
