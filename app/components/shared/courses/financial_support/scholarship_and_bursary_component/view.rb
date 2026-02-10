# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module ScholarshipAndBursaryComponent
        class View < ViewComponent::Base
          attr_reader :course

          delegate :scholarship_amount,
                   :bursary_amount,
                   :has_early_career_payments?,
                   to: :course

          def initialize(course)
            super
            @course = course
          end

          def scholarship_body
            I18n.t("find.scholarships.#{subject_with_scholarship}.body", default: nil)
          end

          def scholarship_url
            I18n.t("find.scholarships.#{subject_with_scholarship}.url", default: nil)
          end

          def bursary_and_scholarship_eligible_subjects
            course.course_subjects.any? { |subject| eligible_subjects.include?(subject.subject.subject_name) }
          end

        private

          def eligible_subjects
            FundingInformation::NON_UK_SCHOLARSHIP_ELIGIBLE_SUBJECTS
          end

          def subject_with_scholarship
            @subject_with_scholarship ||= FundingInformation::SCHOLARSHIP_BODY_SUBJECTS.detect { |subject_code, _subject_name|
              course.subjects.any? do |subject|
                subject.subject_code == subject_code
              end
            }&.second
          end
        end
      end
    end
  end
end
