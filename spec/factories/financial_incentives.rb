# frozen_string_literal: true

FactoryBot.define do
  # TODO: use known subject list
  factory :financial_incentive do
    bursary_amount { nil }
    early_career_payments { nil }
    scholarship { nil }
    non_uk_bursary_eligible { false }
    non_uk_scholarship_eligible { false }
  end
end
