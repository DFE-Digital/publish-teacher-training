# frozen_string_literal: true

module Find
  module Courses
    module FinancialSupport
      module FeesAndFinancialSupportComponent
        class View < ViewComponent::Base
          include PublishHelper

          attr_reader :course

          delegate :salaried?,
            :excluded_from_bursary?,
            :bursary_only?,
            :has_scholarship_and_bursary?,
            :has_fees?,
            :financial_support, to: :course

          def initialize(course)
            super
            @course = course
          end
        end
      end
    end
  end
end
