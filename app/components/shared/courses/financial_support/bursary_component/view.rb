# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module BursaryComponent
        class View < ViewComponent::Base
          attr_reader :course

          delegate :max_bursary_amount, :bursary_requirements,
                   :bursary_first_line_ending, :non_uk_bursary_eligible?,
                   to: :financial_support

          def initialize(course)
            super
            @course = course
            @financial_support = CourseFinancialSupport.new(course)
          end

          # Template uses `bursary_amount` for display — maps to max across all subjects
          def bursary_amount
            financial_support.max_bursary_amount
          end

          def bursary_eligible_subjects
            non_uk_bursary_eligible?
          end

          private

          attr_reader :financial_support
        end
      end
    end
  end
end
