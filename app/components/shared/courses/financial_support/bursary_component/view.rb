# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module BursaryComponent
        class View < ViewComponent::Base
          attr_reader :incentive_view

          delegate :bursary_amount,
                   :bursary_requirements,
                   :bursary_eligible_subjects?, to: :incentive_view
          alias_method :bursary_eligible_subjects, :bursary_eligible_subjects?

          def initialize(incentive_view)
            super()
            @incentive_view = incentive_view
          end
        end
      end
    end
  end
end
