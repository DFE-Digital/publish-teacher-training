# frozen_string_literal: true

class CourseFunding
  # Course name patterns excluded from bursary despite subject eligibility.
  # Only applies to courses with 2 subjects and "with" in the name.
  BURSARY_EXCLUDED_COURSE_PATTERNS = [
    /^Drama/,
    /^Media Studies/,
    /^PE/,
    /^Physical/,
  ].freeze

  attr_reader :course

  def initialize(course)
    @course = course
  end

  def financial_incentive
    # Ignore "modern languages" as financial incentives
    # differ based on the language selected
    course.subjects.reject { |subject| subject.subject_name == "Modern Languages" }.first&.financial_incentive
  end

  def bursary_amount
    financial_incentive&.bursary_amount
  end

  def scholarship_amount
    financial_incentive&.scholarship
  end

  def has_bursary?
    bursary_amount.present?
  end

  def has_scholarship?
    scholarship_amount.present?
  end

  def has_scholarship_and_bursary?
    has_scholarship? && has_bursary?
  end

  def has_early_career_payments?
    financial_incentive&.early_career_payments.present?
  end

  def max_bursary_amount
    find_max_funding_for("bursary_amount")
  end

  def max_scholarship_amount
    find_max_funding_for("scholarship")
  end

  def bursary_only?
    has_bursary? && !has_scholarship?
  end

  def excluded_from_bursary?
    course.subjects.present? &&
      course.subjects.count == 2 &&
      has_excluded_course_name?
  end

  def bursary_eligible_subjects?
    course.subjects.any? { |s| s.financial_incentive&.non_uk_bursary_eligible? }
  end

  def scholarship_eligible_subjects?
    course.subjects.any? { |s| s.financial_incentive&.non_uk_scholarship_eligible? }
  end

  def non_uk_funding_available?
    bursary_eligible_subjects? || scholarship_eligible_subjects?
  end

  # return the downcased subject name if the courses subject has a scholarship
  def subject_with_scholarship
    @subject_with_scholarship ||= course.subjects
      .find { |s| s.financial_incentive&.scholarship.present? }
      &.subject_name&.downcase
  end

private

  def find_max_funding_for(attribute)
    course.subjects
      .filter_map { |s| s.financial_incentive&.public_send(attribute)&.to_i }
      .max.to_s
  end

  def has_excluded_course_name?
    return false unless /with/.match?(course.name)

    BURSARY_EXCLUDED_COURSE_PATTERNS.any? { |e| e.match?(course.name) }
  end
end
