# frozen_string_literal: true

module Publish
  module Courses
    class AssignTdaAttributesService
      def initialize(course)
        @course = course
      end

      def call
        @course.update(
          funding_type: 'apprenticeship',
          study_mode: 'full_time',
          program_type: 'teacher_degree_apprenticeship',
          can_sponsor_student_visa: false,
          can_sponsor_skilled_worker_visa: false,
          degree_grade: 'not_required',
          additional_degree_subject_requirements: false,
          degree_subject_requirements: false
        )

        if @course.enrichments.blank?
          course_enrichment = @course.enrichments.find_or_initialize_draft
          course_enrichment.course_length = '4 years'
        else
          @course.enrichments.max_by(&:created_at).update(course_length: '4 years')
        end
      end
    end
  end
end
