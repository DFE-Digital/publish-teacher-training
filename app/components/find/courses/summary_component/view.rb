# frozen_string_literal: true

module Find
  module Courses
    module SummaryComponent
      class View < ViewComponent::Base
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
                 :study_mode,
                 :salaried?,
                 :can_sponsor_student_visa,
                 :can_sponsor_skilled_worker_visa, to: :course

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

        def visa_sponsorship_row
          if !salaried? && can_sponsor_student_visa
            'Student visas can be sponsored'
          elsif salaried? && can_sponsor_skilled_worker_visa
            'Skilled Worker visas can be sponsored'
          else
            'Visas cannot be sponsored'
          end
        end
      end
    end
  end
end
