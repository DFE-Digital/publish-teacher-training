# frozen_string_literal: true

module Find
  module FinancialIncentiveHelper
    include ActiveSupport::NumberHelper
    include ActionView::Helpers::TagHelper

    def financial_information(financial_incentive)
      return unless FeatureFlag.active?(:bursaries_and_scholarships_announced) && financial_incentive.present?

      content =
        FinancialIncentiveHintHelper.hint_text(
          bursary_amount: financial_incentive.bursary_amount,
          scholarship_amount: financial_incentive.scholarship,
        )

      content_tag(:p, content, class: "govuk-hint govuk-!-font-size-16 govuk-!-margin-top-0 govuk-!-margin-bottom-0") if content
    end
  end
end
