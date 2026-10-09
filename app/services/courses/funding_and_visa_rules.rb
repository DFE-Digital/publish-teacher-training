# frozen_string_literal: true

module Courses
  # The rules that keep a course's funding, visa and enrichment fields
  # consistent after its funding changes. Shared by CourseFundingForm and
  # the course edit wizard's UpdateCourse.
  class FundingAndVisaRules
    def initialize(course)
      @course = course
    end

    # A fee-paying course cannot sponsor Skilled Worker visas, and a
    # salaried or apprenticeship course cannot sponsor student visas.
    def reset_opposite_visa
      if course.fee?
        course.can_sponsor_skilled_worker_visa = false
      else
        course.can_sponsor_student_visa = false
      end
    end

    # A course that sponsors no visa has no visa sponsorship deadline.
    def clear_deadline_unless_sponsoring
      course.visa_sponsorship_application_deadline_at = nil if course.no_visa_sponsorship?
    end

    # Clears the enrichment fields of the other funding type: fees and
    # financial support for a salaried course, salary details for a
    # fee-paying one. Returns the draft enrichment it changed, unsaved, or
    # nil when the course has none.
    def reset_enrichment
      enrichment = course.enrichments.find_or_initialize_draft
      return unless enrichment.persisted?

      enrichment.assign_attributes(enrichment_resets)
      enrichment
    end

  private

    attr_reader :course

    def enrichment_resets
      if course.fee?
        { salary_details: nil }
      else
        { fee_international: nil, fee_uk_eu: nil, financial_support: nil }
      end
    end
  end
end
