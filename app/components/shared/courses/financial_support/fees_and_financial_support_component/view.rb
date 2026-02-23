# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module FeesAndFinancialSupportComponent
        class View < ViewComponent::Base
          include PublishHelper

          attr_reader :course, :enrichment

          delegate :salaried?,
                   :excluded_from_bursary?,
                   :bursary_only?,
                   :has_scholarship_and_bursary?,
                   :has_fees?,
                   :financial_support, to: :course

          def initialize(course, enrichment)
            super()
            @course = course
            @enrichment = enrichment
          end
        end
      end
    end
  end
end
