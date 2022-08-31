module FindInterface
  module Courses
    class QualificationsSummaryComponent::View < ViewComponent::Base
      include ApplicationHelper
      include ViewHelper

      attr_reader :find_outcome

      def initialize(find_outcome)
        super
        @find_outcome = find_outcome
      end
    end
  end
end
