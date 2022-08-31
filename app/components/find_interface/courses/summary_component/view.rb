module FindInterface
  module Courses
    class SummaryComponent::View < ViewComponent::Base
      include ApplicationHelper
      include ViewHelper

      attr_reader :course
      delegate :accrediting_provider,
        :provider,
        :funding_option,
        :age_range_in_years,
        :length,
        :applications_open_from,
        :find_outcome,
        :start_date, to: :course

      def initialize(course)
        super
        @course = course
      end
    end
  end
end
