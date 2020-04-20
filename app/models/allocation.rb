class Allocation < ApplicationRecord
  belongs_to :provider
  belongs_to :accredited_body, class_name: "Provider"

  validates :provider, :accredited_body, presence: true
  validate :accredited_body_is_an_accredited_body

private

  def accredited_body_is_an_accredited_body
    errors.add(:accredited_body, "must be an accredited body") unless accredited_body&.accredited_body?
  end
end
