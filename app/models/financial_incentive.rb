# frozen_string_literal: true

class FinancialIncentive < ApplicationRecord
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
