# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module BursaryComponent
        class View < ViewComponent::Base
          attr_reader :incentive_view

          delegate :bursary_amount,
                   :bursary_first_line_ending,
                   :bursary_requirements,
                   :bursary_eligible_subjects?,
                   :degree_dependent?, to: :incentive_view
          alias_method :bursary_eligible_subjects, :bursary_eligible_subjects?

          def initialize(incentive_view)
            super()
            @incentive_view = incentive_view
          end

          def bursary_amount_text
            key = degree_dependent? ? "bursary_up_to_amount" : "bursary_amount"
            t("find.financial_support.#{key}", amount: number_to_currency(bursary_amount))
          end
        end
      end
    end
  end
end
