# == Schema Information
#
# Table name: allocation
#
#  accredited_body_id :bigint
#  created_at         :datetime         not null
#  id                 :bigint           not null, primary key
#  number_of_places   :integer
#  provider_id        :bigint
#  request_type       :integer          default("initial")
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_allocation_on_accredited_body_id  (accredited_body_id)
#  index_allocation_on_provider_id         (provider_id)
#  index_allocation_on_request_type        (request_type)
#
class Allocation < ApplicationRecord
  belongs_to :provider
  belongs_to :accredited_body, class_name: "Provider"

  validates :provider, :accredited_body, presence: true
  validate :accredited_body_is_an_accredited_body
  validates :number_of_places, numericality: true

  enum request_type: { initial: 0, repeat: 1, declined: 2 }

  # TODO move this out to Create and Update services so as we can handle
  # the difference between update and create more easily once it is fully
  # implemented.
  before_create do
    default_number_of_places = 0

    if self.number_of_places == default_number_of_places
      self.number_of_places = 0 if declined?
      # TODO temporary until we implement fetching the previous
      # Allocation#number_of_places for repeat
      self.number_of_places = 42 if repeat?
    end
  end

private

  def accredited_body_is_an_accredited_body
    errors.add(:accredited_body, "must be an accredited body") unless accredited_body&.accredited_body?
  end
end
