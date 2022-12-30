module Find
  module Courses
    class SummaryComponent::View < ViewComponent::Base
      include ApplicationHelper
      include ::ViewHelper

      attr_reader :course
      delegate :accrediting_provider,
        :provider,
        :funding_option,
        :age_range_in_years,
        :length,
        :applications_open_from,
        :find_outcome,
        :start_date,
        :secondary_course?,
        :level,
        :study_mode, to: :course

      def initialize(course)
        super
        @course = course
      end

      def age_range_in_years_row
        if secondary_course?
          "#{age_range_in_years.humanize} - #{level}"
        else
          age_range_in_years.humanize
        end
      end

      def course_length_with_study_mode_row
        "#{length} - #{study_mode.humanize.downcase}"
      end
    end
  end
end
