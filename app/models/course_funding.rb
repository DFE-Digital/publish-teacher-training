# frozen_string_literal: true

class CourseFunding
  attr_reader :course

  def initialize(course)
    @course = course
  end

  def bursary_amount
    find_max_funding_for(:bursary_amount)
  end

  def scholarship_amount
    find_max_funding_for(:scholarship, scholarship_relevant_subjects)
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
    funding_relevant_subjects.any? { |s| s.financial_incentive&.early_career_payments.present? }
  end

  def bursary_only?
    has_bursary? && !has_scholarship?
  end

  def bursary_eligible_subjects?
    funding_relevant_subjects.any? { |s| s.financial_incentive&.non_uk_bursary_eligible? }
  end

  def scholarship_eligible_subjects?
    scholarship_relevant_subjects.any? { |s| s.financial_incentive&.non_uk_scholarship_eligible? }
  end

  def non_uk_funding_available?
    bursary_eligible_subjects? || scholarship_eligible_subjects?
  end

  def subject_with_scholarship
    @subject_with_scholarship ||= scholarship_relevant_subjects
      .find { |s| s.financial_incentive&.scholarship.present? }
      &.subject_name&.downcase
  end

private

  def find_max_funding_for(attribute, subjects = funding_relevant_subjects)
    subjects
      .filter_map { |s| s.financial_incentive&.public_send(attribute)&.to_i }
      .max&.to_s
  end

  def funding_relevant_subjects
    @funding_relevant_subjects ||= determine_funding_relevant_subjects
  end

  def determine_funding_relevant_subjects
    return [] if course.salary? || course.apprenticeship?
    return [subordinate_subject].compact if science_with_specialist_subordinate?

    subjects = without_subordinate

    if modern_languages_master?
      language_subjects = subjects.select(&:language_subject?)
      return language_subjects if language_subjects.any?
    end

    subjects
  end

  # Returns all subjects up to the position of the subordinate subject
  # This prevents us returning subjects that appear after the subordinate
  def without_subordinate
    return course.subjects if course.subordinate_subject_id.blank?

    subordinate_index = course.subjects.index(subordinate_subject)
    subordinate_index ? course.subjects.first(subordinate_index) : course.subjects
  end

  def master_subject
    @master_subject ||= course.subjects.find { |s| s.id == course.master_subject_id }
  end

  def subordinate_subject
    @subordinate_subject ||= course.subjects.find { |s| s.id == course.subordinate_subject_id }
  end

  def science_with_specialist_subordinate?
    master_subject&.subject_name == "Science" &&
      subordinate_subject&.science_subject?
  end

  def modern_languages_master?
    master_subject&.modern_languages?
  end

  def scholarship_relevant_subjects
    @scholarship_relevant_subjects ||= if modern_languages_master? && !all_language_subjects_have_scholarship?
                                         []
                                       else
                                         funding_relevant_subjects
                                       end
  end

  def all_language_subjects_have_scholarship?
    funding_relevant_subjects.all? { |s| s.financial_incentive&.scholarship.present? }
  end
end
