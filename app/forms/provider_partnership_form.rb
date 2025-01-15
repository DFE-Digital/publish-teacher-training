# frozen_string_literal: true

class ProviderPartnershipForm < Form
  delegate :provider_name, to: :accredited_provider

  FIELDS = %i[
    description
    accredited_provider_id
  ].freeze

  attr_accessor(*FIELDS)

  validates :description, presence: true, words_count: { maximum: 100, message: :too_long }

  alias compute_fields new_attributes

  def accredited_provider
    @accredited_provider ||= Provider.find(accredited_provider_id)
  end

  private

  def assign_attributes_to_model
    if model.persisted?
      model.description = description
    else
      model.accredited_partnerships.build(accredited_provider_id: accredited_provider_id, description: description)
    end
  end
end
