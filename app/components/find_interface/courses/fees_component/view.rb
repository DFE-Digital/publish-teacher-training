module FindInterface
  module Courses
    class FeesComponent::View < ViewComponent::Base
      include PublishHelper
      attr_reader :course

      delegate :fee_uk_eu,
        :fee_international,
        :cycle_range,
        :fee_details, to: :course

      def initialize(course)
        super
        @course = course
      end
    end
  end
end
