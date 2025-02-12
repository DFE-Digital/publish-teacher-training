# frozen_string_literal: true

module Find
  module FinancialIncentiveHelper
    include ActiveSupport::NumberHelper

    def financial_information(financial_incentive)
      return unless FeatureFlag.active?(:bursaries_and_scholarships_announced) && financial_incentive.present?

      scholarship = financial_incentive.scholarship
      bursary = financial_incentive.bursary_amount

      if scholarship && bursary
        I18n.t(
          '.find.v2.subjects.fee_value.fee.hint.bursaries_and_scholarship_html',
          bursary_amount: number_to_currency(bursary),
          scholarship_amount: number_to_currency(scholarship)
        )
      elsif scholarship
        I18n.t('.find.v2.subjects.fee_value.fee.hint.scholarship_only_html', scholarship_amount: number_to_currency(scholarship))
      elsif bursary
        I18n.t('.find.v2.subjects.fee_value.fee.hint.bursaries_only_html', bursary_amount: number_to_currency(bursary))
      end
    end
  end
end
