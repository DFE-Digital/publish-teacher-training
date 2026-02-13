# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module ScholarshipAndBursaryComponent
        class View < ViewComponent::Base
          attr_reader :course

          delegate :early_career_payments?,
                   :non_uk_scholarship_and_bursary_eligible?,
                   to: :financial_support

          def initialize(course)
            super
            @course = course
            @financial_support = CourseFinancialSupport.new(course)
          end

          # Template uses these for display — maps to max across all subjects
          def scholarship_amount
            financial_support.max_scholarship_amount
          end

          def bursary_amount
            financial_support.max_bursary_amount
          end

          def has_early_career_payments?
            early_career_payments?
          end

          def scholarship_body
            key = financial_support.scholarship_body_key
            I18n.t("find.scholarships.#{key}.body", default: nil) if key
          end

          def scholarship_url
            key = financial_support.scholarship_body_key
            I18n.t("find.scholarships.#{key}.url", default: nil) if key
          end

          def bursary_and_scholarship_eligible_subjects
            non_uk_scholarship_and_bursary_eligible?
          end

          private

          attr_reader :financial_support
        end
      end
    end
  end
end
