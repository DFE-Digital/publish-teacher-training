module WithFinancialIncentives
  extend ActiveSupport::Concern

  included do
    def has_bursary?
      dfe_subjects.any?(&:has_bursary?)
    end

    def has_scholarship_and_bursary?
      dfe_subjects.any?(&:has_scholarship_and_bursary?)
    end

    def has_early_career_payments?
      dfe_subjects.any?(&:has_early_career_payments?)
    end

    def bursary_amount
      dfe_subject_which_defines_financial_incentives&.bursary_amount || 0
    end

    def scholarship_amount
      dfe_subject_which_defines_financial_incentives&.scholarship_amount || 0
    end

  private

    def dfe_subject_which_defines_financial_incentives
      dfe_subjects.max_by(&:total_bursary_and_early_career_payments_amount)
    end
  end
end
