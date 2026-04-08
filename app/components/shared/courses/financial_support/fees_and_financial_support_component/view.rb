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

          delegate :bursary_only?,
                   :has_scholarship_and_bursary?, to: :funding_view

          def initialize(course, enrichment)
            super()
            @course = course
            @enrichment = enrichment
          end

          def funding_view
            @funding_view ||= CourseIncentive::View.new(CourseIncentive.new(course))
          end
        end
      end
    end
  end
end
