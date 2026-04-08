# frozen_string_literal: true

class CourseIncentive::View
  include ActiveSupport::NumberHelper

  delegate :has_bursary?, :has_scholarship?, :has_scholarship_and_bursary?,
           :bursary_only?, :has_early_career_payments?,
           :bursary_amount, :scholarship_amount,
           :bursary_eligible_subjects?,
           :scholarship_eligible_subjects?, :non_uk_funding_available?,
           :subject_with_scholarship,
           to: :course_incentive

  def initialize(course_incentive)
    @course_incentive = course_incentive
  end

  def bursary_requirements
    return [] unless has_bursary?

    requirements = [I18n.t("course.values.bursary_requirements.second_degree")]
    mathematics_requirement = I18n.t("course.values.bursary_requirements.maths")

    requirements.push(mathematics_requirement) if course.subjects.any? { |subject| subject.subject_name == "Primary with mathematics" }

    requirements
  end

  # This method is not coupled with a course like the others
  # We can pass arbitrary values in for burasry and scholarship
  # This is specifically used for rendering content about financial incentives
  # directly with secondary subjects rather than course
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

  def bursary_and_scholarship_flag_active_or_preview?
    FeatureFlag.active?(:bursaries_and_scholarships_announced)
  end

  def scholarship_body
    I18n.t("find.scholarships.#{subject_with_scholarship}.body", default: nil)
  end

  def scholarship_url
    I18n.t("find.scholarships.#{subject_with_scholarship}.url", default: nil)
  end

private

  attr_reader :course_incentive

  def course
    course_incentive.course
  end
end
