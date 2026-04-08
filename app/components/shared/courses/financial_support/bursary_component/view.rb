# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module BursaryComponent
        class View < ViewComponent::Base
          attr_reader :funding_view

          delegate :bursary_amount,
                   :bursary_first_line_ending,
                   :bursary_requirements,
                   :bursary_eligible_subjects?, to: :funding_view
          alias_method :bursary_eligible_subjects, :bursary_eligible_subjects?

          def initialize(funding_view)
            super()
            @funding_view = funding_view
          end
        end
      end
    end
  end
end
