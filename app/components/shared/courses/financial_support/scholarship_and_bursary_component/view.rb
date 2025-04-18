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

          ELIGIBLE_SUBJECTS = %w[
            Physics
            French
            German
            Spanish
          ].freeze

          SUBJECT_WITH_SCHOLARSHIPS = [
            %w[F1 chemistry],
            %w[11 computing],
            %w[G1 mathematics],
            %w[F3 physics],
            %w[15 french],
            %w[17 german],
            %w[22 spanish],
          ].freeze
          private_constant :SUBJECT_WITH_SCHOLARSHIPS, :ELIGIBLE_SUBJECTS

          def eligible_subjects
            ELIGIBLE_SUBJECTS
          end

          def subject_with_scholarship
            @subject_with_scholarship ||= SUBJECT_WITH_SCHOLARSHIPS.detect { |subject_code, _subject_name|
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
