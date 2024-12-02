# frozen_string_literal: true

class ProviderPartnership < ApplicationRecord
  belongs_to :training_provider, class_name: 'Provider'
  belongs_to :accredited_provider, class_name: 'Provider'

  validate :accredited_provider_must_be_accredited
  validate :training_provider_must_not_be_accredited

  ##
  ##   Validations
  ##

  def accredited_provider_must_be_accredited
    return if accredited_provider.blank?

    accredited_provider.accredited? ||
      errors.add(:accredited_provider, :must_be_accredited)
  end

  def training_provider_must_not_be_accredited
    return if training_provider.blank?

    training_provider.accredited? &&
      errors.add(:training_provider, :must_not_be_accredited)
  end
end
