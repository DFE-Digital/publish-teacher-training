module Find
  module Courses
    module FinancialSupport
      module BursaryComponent
        class View < ViewComponent::Base
          attr_reader :course

          delegate :bursary_amount,
            :bursary_requirements,
            :bursary_first_line_ending, to: :course

          def initialize(course)
            super
            @course = course
          end
        end
      end
    end
  end
end
