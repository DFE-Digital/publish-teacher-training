# frozen_string_literal: true

class CourseFinancialSupport
  LANGUAGE_SUBJECTS = [
    "Ancient Greek",
    "Ancient Hebrew",
    "English",
    "English as a second or other language",
    "French",
    "German",
    "Italian",
    "Japanese",
    "Latin",
    "Mandarin",
    "Modern Languages",
    "Modern languages (other)",
    "Russian",
    "Spanish",
  ].freeze

  EXCLUDED_COURSE_NAME_PATTERNS = [
    /^Drama/,
    /^Media Studies/,
    /^PE/,
    /^Physical/,
  ].freeze

  def initialize(course)
    @course = course
  end

  # --- Core data ---

  def financial_incentive
    @financial_incentive ||= main_subject&.financial_incentive
  end

  def main_subject
    @main_subject ||= if @course.master_subject_id.present?
                         @course.subjects.find { |s| s.id == @course.master_subject_id }
                       else
                         # Fallback: first non-Modern-Languages subject (matches original Course#financial_incentive)
                         @course.subjects.reject { |s| s.subject_name == "Modern Languages" }.first
                       end
  end

  def bursary_amount
    financial_incentive&.bursary_amount
  end

  def scholarship_amount
    financial_incentive&.scholarship
  end

  def max_bursary_amount
    max_funding_for("bursary_amount")
  end

  def max_scholarship_amount
    max_funding_for("scholarship")
  end

  # --- Predicates ---

  def bursary?
    bursary_amount.present?
  end

  def scholarship?
    scholarship_amount.present?
  end

  def scholarship_and_bursary?
    scholarship? && bursary?
  end

  def bursary_only?
    bursary? && !scholarship?
  end

  def excluded_from_bursary?
    @course.subjects.present? &&
      @course.subjects.count == 2 &&
      has_excluded_course_name?
  end

  def early_career_payments?
    financial_incentive&.early_career_payments.present?
  end

  def announced?
    FeatureFlag.active?(:bursaries_and_scholarships_announced)
  end

  # --- Non-UK eligibility ---

  def non_uk_bursary_eligible?
    @course.course_subjects.any? { |cs| cs.subject.non_uk_bursary_eligible? }
  end

  def non_uk_scholarship_and_bursary_eligible?
    @course.course_subjects.any? { |cs| cs.subject.non_uk_scholarship_and_bursary_eligible? }
  end

  # --- Scholarship body ---

  def scholarship_body_key
    @course.subjects.filter_map(&:scholarship_body_key).first
  end

  # --- Requirements ---

  def bursary_requirements
    return [] unless bursary?

    requirements = [I18n.t("course.values.bursary_requirements.second_degree")]

    if @course.subjects.any? { |subject| subject.subject_name == "Primary with mathematics" }
      requirements.push(I18n.t("course.values.bursary_requirements.maths"))
    end

    requirements
  end

  def bursary_first_line_ending
    if bursary_requirements.count > 1
      ":"
    else
      "#{bursary_requirements.first}."
    end
  end

  # --- Search results hint (absorbs FinancialIncentiveHint) ---

  def hint_text(visa_sponsorship: nil)
    return if skip_hint?(visa_sponsorship)

    FinancialIncentiveHintHelper.hint_text(
      bursary_amount: financial_incentive&.bursary_amount,
      scholarship_amount: financial_incentive&.scholarship,
    )
  end

  private

  def skip_hint?(visa_sponsorship)
    @course.salary? || @course.apprenticeship? ||
      !announced? ||
      financial_incentive.blank? ||
      (visa_sponsorship.present? && !main_subject&.physics? && !language_subject?)
  end

  def language_subject?
    main_subject&.subject_name.in?(LANGUAGE_SUBJECTS)
  end

  def has_excluded_course_name?
    return false unless /with/.match?(@course.name)

    EXCLUDED_COURSE_NAME_PATTERNS.any? { |e| e.match?(@course.name) }
  end

  def max_funding_for(attribute)
    amounts = @course.subjects.filter_map do |s|
      next unless s.financial_incentive.present? && s.financial_incentive.attributes[attribute].present?

      s.financial_incentive.public_send(attribute.to_sym).to_i
    end

    amounts.max.to_s
  end
end
