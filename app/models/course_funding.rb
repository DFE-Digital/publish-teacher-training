# frozen_string_literal: true

class CourseFunding
  attr_reader :course

  def initialize(course)
    @course = course
  end

  def financial_incentive
    funding_relevant_subjects.reject { |subject| subject.subject_name == "Modern Languages" }.first&.financial_incentive
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

  def bursary_eligible_subjects?
    funding_relevant_subjects.any? { |s| s.financial_incentive&.non_uk_bursary_eligible? }
  end

  def scholarship_eligible_subjects?
    funding_relevant_subjects.any? { |s| s.financial_incentive&.non_uk_scholarship_eligible? }
  end

  def non_uk_funding_available?
    bursary_eligible_subjects? || scholarship_eligible_subjects?
  end

  # return the downcased subject name if the courses subject has a scholarship
  def subject_with_scholarship
    @subject_with_scholarship ||= funding_relevant_subjects
      .find { |s| s.financial_incentive&.scholarship.present? }
      &.subject_name&.downcase
  end

private

  def find_max_funding_for(attribute)
    subjects = funding_relevant_subjects
    subjects
      .filter_map { |s| s.financial_incentive&.public_send(attribute)&.to_i }
      .max.to_s
  end

  def funding_relevant_subjects
    return course.subjects if course.subordinate_subject_id.blank?

    if science_with_specialist_subordinate?
      return course.subjects.select { |s| s.id == course.subordinate_subject_id }
    end

    subjects = course.subjects.reject { |s| s.id == course.subordinate_subject_id }

    if modern_languages_master?
      language_subjects = subjects.select { |s| s.is_a?(ModernLanguagesSubject) }
      return language_subjects if language_subjects.present?
    end

    subjects
  end

  SCIENCE_SPECIALIST_SUBJECT_NAMES = %w[Physics Chemistry Biology].freeze

  def science_with_specialist_subordinate?
    master = course.subjects.find { |s| s.id == course.master_subject_id }
    return false unless master&.subject_name == "Science"

    subordinate = course.subjects.find { |s| s.id == course.subordinate_subject_id }
    subordinate&.subject_name&.in?(SCIENCE_SPECIALIST_SUBJECT_NAMES)
  end

  def modern_languages_master?
    master = course.subjects.find { |s| s.id == course.master_subject_id }
    master&.subject_name == "Modern Languages"
  end
end
