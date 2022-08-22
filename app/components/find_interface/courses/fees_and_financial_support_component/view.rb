module FindInterface
  module Courses
    class FeesAndFinancialSupportComponent::View < ViewComponent::Base
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
