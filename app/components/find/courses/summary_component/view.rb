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

        def course_fee_value
          safe_join([formatted_uk_eu_fee_label, tag.br, formatted_international_fee_label])
        end

        def formatted_uk_eu_fee_label
          return if course.fee_uk_eu.blank?

          "UK students: #{number_to_currency(course.fee_uk_eu)}"
        end

        def formatted_international_fee_label
          return if course.fee_international.blank?

          "International students: #{number_to_currency(course.fee_international)}"
        end

        def no_fee?
          course.fee_international.blank? && course.fee_uk_eu.blank?
        end

        def applications_open_from_date_has_passed?
          course.applications_open_from <= Time.zone.today
        end
      end
    end
  end
end
