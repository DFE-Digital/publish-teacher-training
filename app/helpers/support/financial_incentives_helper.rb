# frozen_string_literal: true

module Support
  module FinancialIncentivesHelper
    STATUS_COLOURS = {
      hidden: "grey",
      missing: "red",
      visible: "green",
    }.freeze

    def financial_incentive_amount(amount)
      amount.present? ? number_to_currency(amount.to_i, precision: 0) : t(".values.none")
    end

    def financial_incentive_yes_no(value)
      key = value ? :yes : :no

      t(".values.#{key}")
    end

    def financial_incentive_status_tag(financial_incentive)
      status = financial_incentive_status(financial_incentive)

      govuk_tag(text: t(".statuses.#{status}"), colour: STATUS_COLOURS.fetch(status))
    end

  private

    def financial_incentive_status(financial_incentive)
      return :missing if financial_incentive.blank?

      financial_incentive.displayed? ? :visible : :hidden
    end
  end
end
