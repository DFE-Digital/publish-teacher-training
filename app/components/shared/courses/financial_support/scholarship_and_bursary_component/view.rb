# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module ScholarshipAndBursaryComponent
        class View < ViewComponent::Base
          attr_reader :funding_view

          delegate :max_scholarship_amount,
                   :max_bursary_amount,
                   :has_early_career_payments?,
                   :scholarship_eligible_subjects?,
                   :scholarship_body,
                   :scholarship_url, to: :funding_view

          alias_method :scholarship_amount, :max_scholarship_amount
          alias_method :bursary_amount, :max_bursary_amount
          alias_method :bursary_and_scholarship_eligible_subjects, :scholarship_eligible_subjects?

          def initialize(funding_view)
            super()
            @funding_view = funding_view
          end
        end
      end
    end
  end
end
