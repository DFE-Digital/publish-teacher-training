# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module FeesAndFinancialSupportComponent
        class View < ViewComponent::Base
          include PublishHelper

          attr_reader :course, :enrichment

          delegate :salaried?,
                   :has_fees?,
                   :financial_support, to: :course

          delegate :excluded_from_bursary?,
                   :bursary_only?,
                   :scholarship_and_bursary?,
                   to: :financial_support

          def initialize(course, enrichment)
            super
            @course = course
            @enrichment = enrichment
            @financial_support = CourseFinancialSupport.new(course)
          end

          private

          attr_reader :financial_support
        end
      end
    end
  end
end
