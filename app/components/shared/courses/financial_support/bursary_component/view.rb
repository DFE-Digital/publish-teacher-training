# frozen_string_literal: true

module Shared
  module Courses
    module FinancialSupport
      module BursaryComponent
        class View < ViewComponent::Base
          attr_reader :course

          delegate :bursary_amount,
                   :bursary_requirements,
                   :bursary_first_line_ending, to: :course

          def initialize(course)
            super
            @course = course
          end

          def bursary_eligible_subjects
            course.course_subjects.any? { |subject| eligible_subjects.include?(subject.subject.subject_name) }
          end

        private

          ELIGIBLE_SUBJECTS = [
            "Italian",
            "Japanese",
            "Mandarin",
            "Russian",
            "Modern languages (other)",
            "Ancient Greek",
            "Ancient Hebrew",
          ].freeze
          private_constant :ELIGIBLE_SUBJECTS

          def eligible_subjects
            ELIGIBLE_SUBJECTS
          end
        end
      end
    end
  end
end
