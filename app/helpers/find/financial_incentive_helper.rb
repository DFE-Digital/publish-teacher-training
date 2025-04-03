# frozen_string_literal: true

module Find
  module FinancialIncentiveHelper
    include ActiveSupport::NumberHelper
    include ActionView::Helpers::TagHelper

    def financial_information(financial_incentive)
      return unless FeatureFlag.active?(:bursaries_and_scholarships_announced) && financial_incentive.present?

      scholarship = financial_incentive.scholarship
      bursary = financial_incentive.bursary_amount

      content = if scholarship && bursary
                  I18n.t(
                    ".find.subjects.fee_value.fee.hint.bursaries_and_scholarship_html",
                    bursary_amount: number_to_currency(bursary),
                    scholarship_amount: number_to_currency(scholarship),
                  )
                elsif scholarship
                  I18n.t(".find.subjects.fee_value.fee.hint.scholarship_only_html", scholarship_amount: number_to_currency(scholarship))
                elsif bursary
                  I18n.t(".find.subjects.fee_value.fee.hint.bursaries_only_html", bursary_amount: number_to_currency(bursary))
                end

      content_tag(:p, content, class: "govuk-hint govuk-!-font-size-16 govuk-!-margin-top-0 govuk-!-margin-bottom-0") if content
    end
  end
end
