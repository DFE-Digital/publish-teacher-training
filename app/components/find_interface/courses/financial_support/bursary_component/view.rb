module FindInterface
  module Courses
    module FinancialSupport
      class BursaryComponent::View < ViewComponent::Base
        attr_reader :course

        delegate :bursary_amount,
          :bursary_requirements,
          :bursary_first_line_ending, to: :course

        def initialize(course)
          super
          @course = course
        end

        def duplicate_requirement(requirement)
          bursary_first_line_ending.sub!(/[.:]$/, "") == requirement
        end
      end
    end
  end
end
