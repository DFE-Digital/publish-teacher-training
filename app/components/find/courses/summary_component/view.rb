# frozen_string_literal: true

module Find
  module Courses
    module SummaryComponent
      class View < ViewComponent::Base
        include ApplicationHelper
        include ::ViewHelper
        include PreviewHelper

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
                 :can_sponsor_skilled_worker_visa,
                 :no_fee?, to: :course

        def initialize(course)
          super
          @course = course
        end

        def fee_value
          if course.salary? || course.apprenticeship?
            t(".fee_value.#{course.funding}")
          else
            safe_join([uk_fees, international_fees].compact_blank, tag.br)
          end
        end

        def fee_hint
          return if course.salary? || course.apprenticeship? || hide_fee_hint?

          if financial_incentive.bursary_amount.present? && financial_incentive.scholarship.present?
            t(
              ".fee_value.fee.hint.bursaries_and_scholarship_html",
              bursary_amount: number_to_currency(financial_incentive.bursary_amount),
              scholarship_amount: number_to_currency(financial_incentive.scholarship),
            )
          elsif financial_incentive.bursary_amount.present?
            t(
              ".fee_value.fee.hint.bursaries_only_html",
              bursary_amount: number_to_currency(financial_incentive.bursary_amount),
            )
          elsif financial_incentive.scholarship.present?
            t(
              ".fee_value.fee.hint.scholarship_only_html",
              scholarship_amount: number_to_currency(financial_incentive.scholarship),
            )
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
          "#{length} - #{study_mode.humanize.downcase}"
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

        def uk_fees(fee_uk = course.enrichment_attribute(:fee_uk_eu))
          t(".fee_value.fee.uk_fees_html", value: content_tag(:b, number_to_currency(fee_uk.to_f))) if fee_uk.present?
        end

        def international_fees(fee_international = course.enrichment_attribute(:fee_international))
          t(".fee_value.fee.international_fees_html", value: content_tag(:b, number_to_currency(fee_international.to_f))) if fee_international.present?
        end

        def hide_fee_hint?
          !bursary_and_scholarship_flag_active_or_preview? ||
            (search_by_visa_sponsorship? && !physics? && !languages?) ||
            financial_incentive.blank?
        end

        def bursary_and_scholarship_flag_active_or_preview?
          FeatureFlag.active?(:bursaries_and_scholarships_announced)
        end

        def search_by_visa_sponsorship?
          @visa_sponsorship.present?
        end

        def main_subject
          @main_subject ||= Subject.find_by(id: course.master_subject_id)
        end

        PHYSICS_SUBJECT = "Physics"
        private_constant :PHYSICS_SUBJECT

        def physics?
          main_subject&.subject_name == PHYSICS_SUBJECT
        end

        LANGUAGE_SUBJECTS = [
          "Ancient Greek",
          "Ancient Hebrew",
          "English",
          "English as a second or other language",
          "French",
          "German",
          "Italian",
          "Japanese",
          "Latin",
          "Mandarin",
          "Modern Languages",
          "Modern languages (other)",
          "Russian",
          "Spanish",
        ].freeze
        private_constant :LANGUAGE_SUBJECTS

        def languages?
          main_subject&.subject_name.in?(LANGUAGE_SUBJECTS)
        end

        def financial_incentive
          @financial_incentive ||= main_subject&.financial_incentive
        end
      end
    end
  end
end
