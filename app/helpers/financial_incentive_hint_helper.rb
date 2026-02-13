# frozen_string_literal: true

module FinancialIncentiveHintHelper
  def self.hint_text(bursary_amount:, scholarship_amount:)
    bursary = bursary_amount.presence
    scholarship = scholarship_amount.presence

    return if bursary.blank? && scholarship.blank?

    if bursary.present? && scholarship.present?
      I18n.t(
        "financial_incentive.hint.bursaries_and_scholarship",
        bursary_amount: ActiveSupport::NumberHelper.number_to_currency(bursary),
        scholarship_amount: ActiveSupport::NumberHelper.number_to_currency(scholarship),
      )
    elsif bursary.present?
      I18n.t(
        "financial_incentive.hint.bursaries_only",
        bursary_amount: ActiveSupport::NumberHelper.number_to_currency(bursary),
      )
    else
      I18n.t(
        "financial_incentive.hint.scholarship_only",
        scholarship_amount: ActiveSupport::NumberHelper.number_to_currency(scholarship),
      )
    end
  end
end
