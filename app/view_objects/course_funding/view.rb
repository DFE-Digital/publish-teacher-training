# frozen_string_literal: true

class CourseFunding::View
  include ActiveSupport::NumberHelper

  delegate :has_bursary?, :has_scholarship?, :has_scholarship_and_bursary?,
           :bursary_only?, :has_early_career_payments?,
           :bursary_amount, :scholarship_amount,
           :bursary_eligible_subjects?,
           :scholarship_eligible_subjects?, :non_uk_funding_available?,
           :subject_with_scholarship,
           to: :course_funding

  def initialize(course_funding)
    @course_funding = course_funding
  end

  def bursary_requirements
    return [] unless has_bursary?

    requirements = [I18n.t("course.values.bursary_requirements.second_degree")]
    mathematics_requirement = I18n.t("course.values.bursary_requirements.maths")

    requirements.push(mathematics_requirement) if course.subjects.any? { |subject| subject.subject_name == "Primary with mathematics" }

    requirements
  end

  def bursary_first_line_ending
    if bursary_requirements.count > 1
      ":"
    else
      "#{bursary_requirements.first}."
    end
  end

  def financial_incentive_details
    return I18n.t("components.course.financial_incentives.not_yet_available") if (course.recruitment_cycle_year.to_i > Find::CycleTimetable.current_year) || !FeatureFlag.active?(:bursaries_and_scholarships_announced)

    formatted_bursary = number_to_currency(bursary_amount)
    formatted_scholarship = number_to_currency(scholarship_amount)

    return I18n.t("components.course.financial_incentives.none") if formatted_bursary.blank? && formatted_scholarship.blank?

    return I18n.t("components.course.financial_incentives.bursary_and_scholarship", scholarship: formatted_scholarship, bursary_amount: formatted_bursary) if formatted_bursary.present? && formatted_scholarship.present?

    I18n.t("components.course.financial_incentives.bursary", amount: formatted_bursary)
  end

  def self.hint_text(bursary_amount:, scholarship_amount:, non_uk_funding_available: true)
    bursary = bursary_amount.presence
    scholarship = scholarship_amount.presence

    return if bursary.blank? && scholarship.blank?

    text = if bursary.present? && scholarship.present?
             I18n.t(
               "financial_incentive.hint.bursaries_and_scholarship",
               bursary_amount: ActiveSupport::NumberHelper.number_to_currency(bursary),
               scholarship_amount: ActiveSupport::NumberHelper.number_to_currency(scholarship),
             )
           elsif bursary.present?
             I18n.t(
               "financial_incentive.hint.bursaries_only",
               bursary_amount: ActiveSupport::NumberHelper.number_to_currency(bursary),
             )
           else
             I18n.t(
               "financial_incentive.hint.scholarship_only",
               scholarship_amount: ActiveSupport::NumberHelper.number_to_currency(scholarship),
             )
           end

    text += " for UK citizens" unless non_uk_funding_available
    text
  end

  def hint_text
    self.class.hint_text(
      bursary_amount: bursary_amount,
      scholarship_amount: scholarship_amount,
      non_uk_funding_available: non_uk_funding_available?,
    )
  end

  def scholarship_body
    I18n.t("find.scholarships.#{subject_with_scholarship}.body", default: nil)
  end

  def scholarship_url
    I18n.t("find.scholarships.#{subject_with_scholarship}.url", default: nil)
  end

private

  attr_reader :course_funding

  def course
    course_funding.course
  end
end
