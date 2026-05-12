# frozen_string_literal: true

module Support
  module FinancialIncentivesHelper
    def financial_incentive_amount(amount)
      amount.present? ? number_to_currency(amount.to_i, precision: 0) : t("support.financial_incentives.shared.none")
    end

    def financial_incentive_yes_no(value)
      value ? t("support.financial_incentives.shared.yes") : t("support.financial_incentives.shared.no")
    end

    def financial_incentive_status_tag(financial_incentive)
      return govuk_tag(text: t("support.financial_incentives.shared.missing"), colour: "red") if financial_incentive.blank?

      if financial_incentive.displayed?
        govuk_tag(text: t("support.financial_incentives.shared.visible"), colour: "green")
      else
        govuk_tag(text: t("support.financial_incentives.shared.hidden"), colour: "grey")
      end
    end
  end
end
