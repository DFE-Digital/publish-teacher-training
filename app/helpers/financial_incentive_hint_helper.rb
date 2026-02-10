# frozen_string_literal: true

module FinancialIncentiveHintHelper
  def self.hint_text(bursary_amount:, scholarship_amount:)
    bursary = bursary_amount.presence
    scholarship = scholarship_amount.presence

    return if bursary.blank? && scholarship.blank?

    if bursary.present? && scholarship.present?
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
  end

  def bursary_value
    return if course.salary? || course.apprenticeship? || hide_fee_hint?

    FinancialIncentiveHintHelper.hint_text(
      bursary_amount: financial_incentive&.bursary_amount,
      scholarship_amount: financial_incentive&.scholarship,
    )
  end

  def main_subject
    return if course.master_subject_id.blank?

    @main_subject ||= course.subjects.find { |subject| subject.id == course.master_subject_id }
  end

  def financial_incentive
    @financial_incentive ||= main_subject&.financial_incentive
  end

private

  def hide_fee_hint?
    !bursary_and_scholarship_flag_active? ||
      (search_by_visa_sponsorship? && !physics? && !languages?) ||
      financial_incentive.blank?
  end

  def bursary_and_scholarship_flag_active?
    FeatureFlag.active?(:bursaries_and_scholarships_announced)
  end

  # Components that support this (e.g. Find results / course pages) can override.
  def search_by_visa_sponsorship?
    respond_to?(:visa_sponsorship, true) && visa_sponsorship.present?
  end

  # Components can override these if they have subject-name logic.
  def physics?
    false
  end

  def languages?
    false
  end
end
