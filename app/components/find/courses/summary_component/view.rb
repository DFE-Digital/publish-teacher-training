# frozen_string_literal: true

module Find
  module Courses
    module SummaryComponent
      class View < ViewComponent::Base
        include ApplicationHelper
        include ::ViewHelper
        include PreviewHelper
        attr_reader :course, :enrichment

        delegate :accrediting_provider,
                 :provider,
                 :age_range_in_years,
                 :applications_open_from,
                 :find_outcome,
                 :start_date,
                 :secondary_course?,
                 :level,
                 :study_mode,
                 :salaried?,
                 :can_sponsor_student_visa,
                 :can_sponsor_skilled_worker_visa,
                 :no_fee?, to: :course

        delegate :course_length, to: :enrichment

        def initialize(course, enrichment)
          super()
          @course = course
          @enrichment = enrichment
        end

        def course_length_formatted
          if enrichment.standard_course_length?
            t("courses.summary_card_component.length_value.#{course_length}")
          else
            course_length.to_s
          end
        end

        def fee_value
          if course.salary? || course.apprenticeship?
            t(".fee_value.#{course.funding}")
          else
            safe_join([uk_fees, international_fees].compact_blank, tag.br)
          end
        end

        def age_range_in_years_row
          if secondary_course?
            "#{age_range_in_years.humanize} - #{level}"
          else
            age_range_in_years.humanize
          end
        end

        def course_length_with_study_mode_row
          "#{course_length_formatted} - #{study_mode.humanize.downcase}"
        end

        def visa_sponsorship_row
          if !salaried? && can_sponsor_student_visa
            "Student visas can be sponsored"
          elsif salaried? && can_sponsor_skilled_worker_visa
            "Skilled Worker visas can be sponsored"
          else
            "Visas cannot be sponsored"
          end
        end

        def show_apply_from_row?
          course.applications_open_from&.future?
        end

      private

        def uk_fees(fee_uk = enrichment&.fee_uk_eu)
          t(".fee_value.fee.uk_fees_html", value: content_tag(:b, number_to_currency(fee_uk.to_f))) if fee_uk.present?
        end

        def international_fees(fee_international = enrichment&.fee_international)
          t(".fee_value.fee.international_fees_html", value: content_tag(:b, number_to_currency(fee_international.to_f))) if fee_international.present?
        end

        def incentive_hint
          incentive_view.hint_text
        end

        def incentive_view
          @incentive_view ||= CourseIncentive::View.new(CourseIncentive.new(course))
        end
      end
    end
  end
end
