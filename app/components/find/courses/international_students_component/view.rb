# frozen_string_literal: true

module Find
  module Courses
    module InternationalStudentsComponent
      class View < ViewComponent::Base
        include ::ViewHelper
        include PreviewHelper
        attr_reader :course

        delegate :apprenticeship?,
                 :salaried?,
                 :can_sponsor_student_visa,
                 :can_sponsor_skilled_worker_visa,
                 to: :course

        def initialize(course:)
          super
          @course = course
        end

        def right_required
          if course.salaried?
            'right to work'
          else
            'right to study'
          end
        end

        def visa_type
          @visa_type ||= course.salaried? ? :skilled_worker_visa : :student_visa
        end

        def sponsorship_availability
          @sponsorship_availability ||= course.public_send("can_sponsor_#{visa_type}") ? :available : :not_available
        end

        def course_subject_codes
          @course_subject_codes ||= course.subjects.pluck(:subject_code).compact
        end

        def visa_sponsorship_summary
          if !salaried? && can_sponsor_student_visa
            t('.student_visas_can_be_sponsored')
          elsif salaried? && can_sponsor_skilled_worker_visa
            t('.skilled_worker_visas_can_be_sponsored')
          else
            t('.visas_cannot_be_sponsored')
          end
        end
      end
    end
  end
end
