class Allocation < ApplicationRecord
  belongs_to :provider
  belongs_to :accredited_body, class_name: "Provider"
  belongs_to :recruitment_cycle

  validates :provider, :accredited_body, presence: true
  validates :number_of_places, numericality: true

  validate :accredited_body_is_an_accredited_body

  enum request_type: { initial: 0, repeat: 1, declined: 2 }

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
end
