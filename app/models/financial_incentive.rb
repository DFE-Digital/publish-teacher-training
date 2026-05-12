# frozen_string_literal: true

class FinancialIncentive < ApplicationRecord
  INCENTIVE_ATTRIBUTES = %i[
    bursary_amount
    scholarship
    early_career_payments
    non_uk_bursary_eligible
    non_uk_scholarship_eligible
    subject_knowledge_enhancement_course_available
  ].freeze

  DEFAULT_ATTRIBUTES = {
    bursary_amount: nil,
    scholarship: nil,
    early_career_payments: nil,
    non_uk_bursary_eligible: false,
    non_uk_scholarship_eligible: false,
    subject_knowledge_enhancement_course_available: false,
  }.freeze

  attribute :displayed, default: false
  attribute :year, default: -> { FinancialIncentive.current_year }

  belongs_to :subject

  scope :displayed, -> { where(displayed: true) }
  scope :for_year, ->(year) { where(year: year.to_i) }

  validates :year,
            presence: true,
            numericality: { only_integer: true },
            uniqueness: { scope: :subject_id }
  validates :displayed, uniqueness: { scope: :subject_id }, if: :displayed?

  def self.current_year
    (RecruitmentCycle.current&.year || Find::CycleTimetable.current_year).to_i
  end

  def display!
    subject.with_lock do
      self.class.where(subject_id:, displayed: true).where.not(id:).find_each do |financial_incentive|
        financial_incentive.update!(displayed: false)
      end

      self.displayed = true
      save!
    end
  end
end
