class Allocation < ApplicationRecord
  ALLOCATION_CYCLE_YEAR = Settings.allocation_cycle_year.to_s.freeze

  include PgSearch::Model

  belongs_to :provider
  belongs_to :accredited_body, class_name: "Provider"
  belongs_to :recruitment_cycle
  has_one :allocation_uplift

  audited associated_with: :provider

  validates :provider, :accredited_body, presence: true
  validates :number_of_places, numericality: true

  validate :accredited_body_is_an_accredited_body
  validate :non_zero_initial_request

  enum request_type: { initial: 0, repeat: 1, declined: 2 }

  scope :current_allocations, -> { where(recruitment_cycle: RecruitmentCycle.find_by(year: Settings.allocation_cycle_year)) }

  pg_search_scope :search, associated_against: {
    provider: %i[provider_code provider_name],
    accredited_body: %i[provider_code provider_name],
  }, using: { tsearch: { prefix: true } }

  def previous
    Allocation.find_by(
      provider_code: provider_code,
      accredited_body_code: accredited_body_code,
      recruitment_cycle: recruitment_cycle.previous,
    )
  end

private

  def accredited_body_is_an_accredited_body
    errors.add(:accredited_body, "must be an accredited body") unless accredited_body&.accredited_body?
  end

  def non_zero_initial_request
    errors.add(:number_of_places, "must not be zero") if request_type == "initial" && number_of_places.zero?
  end
end
